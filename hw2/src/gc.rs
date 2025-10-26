use std::{
    alloc::{GlobalAlloc, Layout},
    mem::swap,
};

use crate::{control_block::ControlBlock, print_memory_chunks, types::*};

#[derive(Debug, Default)]
struct GCStats {
    pub total_allocations: usize,
    pub total_allocated_memory: usize,
    pub gc_cycles_started: usize,
    pub gc_cycles_full: usize,
    pub max_residency: usize,
    pub max_residency_memory: usize,
    pub read_count: usize,
    pub write_count: usize,
    pub barrier_triggers: usize,
}

pub struct GarbageCollector {
    heap_layout: Layout,
    roots: Vec<StellaVarOrField>,
    stats: GCStats,

    from_space: *mut u8,
    to_space: *mut u8,
    next: *mut u8,
    limit: *mut u8,
    incremental_state: Option<IncrementalState>,
}

struct IncrementalState {
    scan: *mut u8,
}

impl GarbageCollector {
    pub fn new(max_alloc_size: usize) -> Self {
        let allocated_memory = max_alloc_size * 2;
        let heap_layout = Layout::array::<u8>(allocated_memory).unwrap();
        let ptr = unsafe { std::alloc::System.alloc(heap_layout) };
        let to_space = unsafe { ptr.offset(Self::space_size(allocated_memory) as isize) };
        GarbageCollector {
            heap_layout,
            roots: Vec::new(),
            stats: GCStats::default(),
            from_space: ptr,
            to_space,
            limit: to_space,
            next: ptr,
            incremental_state: None,
        }
    }

    pub fn finalize(&mut self) {
        let smallest = if self.from_space.addr() < self.to_space.addr() {
            self.from_space
        } else {
            self.to_space
        };
        unsafe { std::alloc::System.dealloc(smallest, self.heap_layout()) };
    }

    pub fn allocated_memory(&self) -> usize {
        self.heap_layout.size()
    }

    pub(crate) fn space_size(allocated_memory: usize) -> usize {
        allocated_memory / 2
    }

    fn heap_layout(&self) -> Layout {
        self.heap_layout
    }

    fn scan(&mut self) -> &mut *mut u8 {
        &mut self.incremental_state.as_mut().unwrap().scan
    }

    fn limit(&mut self) -> &mut *mut u8 {
        &mut self.limit
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut StellaObject {
        log::debug!("alloc {}", size_in_bytes);
        let control_block_header_size = ControlBlock::<StellaObject>::header_layout().size();
        let requested_memory_size = control_block_header_size + size_in_bytes;

        self.stats.total_allocations += 1;
        self.stats.total_allocated_memory += requested_memory_size;

        let result = if self.is_collecting() {
            self.allocate_during_collection(requested_memory_size)
        } else {
            if let Some(ptr) = self.regular_allocate(requested_memory_size) {
                ptr
            } else {
                self.init_collection();
                self.allocate_during_collection(requested_memory_size)
            }
        };

        result
    }

    fn allocate_during_collection(&mut self, requested_memory_size: usize) -> *mut StellaObject {
        let new_limit = unsafe { self.limit().offset(-(requested_memory_size as isize)) };
        if new_limit.addr() < self.scan().addr() {
            self.out_of_memory();
            return std::ptr::null_mut();
        }
        *self.limit() = new_limit;

        let mut advanced = 0;
        while self.scan().addr() < self.next.addr() && advanced < requested_memory_size {
            let block = ControlBlock::<StellaObject>::from_ptr(*self.scan());
            let object = block.get_value();
            let field_count = object.get_fields_count();

            for field_idx in 0..field_count as usize {
                let field = &mut object.get_field(field_idx);
                if self.is_managed_ptr(**field) {
                    **field = self.forward(ControlBlock::<StellaObject>::from_var_of_field(field));
                }
            }

            let object_size = ControlBlock::<StellaObject>::get_layout(StellaObject::get_layout(
                field_count as usize,
            ))
            .size();
            let new_scan = unsafe { self.scan().add(object_size) };
            if new_scan.addr() > new_limit.addr() {
                self.out_of_memory();
                return std::ptr::null_mut();
            }
            *self.scan() = new_scan;
            advanced += object_size;
        }

        if advanced > 0 && self.next.addr() == self.scan().addr() {
            self.stop_collection();
        }

        new_limit as *mut StellaObject
    }

    fn regular_allocate(&mut self, requested_memory_size: usize) -> Option<*mut StellaObject> {
        if self.next.addr() + requested_memory_size > self.limit().addr() {
            return None;
        }

        let block = ControlBlock::<StellaObject>::from_ptr(self.next);
        let result = block.get_value().as_ptr();
        log::debug!("space left: {}", self.limit().addr() - result.addr());
        let new_next = unsafe { self.next.add(requested_memory_size) };
        self.next = new_next;
        Some(result)
    }

    fn out_of_memory(&mut self) {
        if log::log_enabled!(log::Level::Debug) {
            self.print_state();
        }
        log::error!("out of memory");
    }

    fn is_collecting(&self) -> bool {
        self.incremental_state.is_some()
    }

    pub fn init_collection(&mut self) {
        log::info!("collection started");
        if log::log_enabled!(log::Level::Debug) {
            self.print_state();
        }

        self.update_stats();

        self.stats.gc_cycles_started += 1;
        self.next = self.to_space;
        self.limit = unsafe { self.to_space.add(Self::space_size(self.allocated_memory())) };
        self.incremental_state = Some(IncrementalState {
            scan: self.to_space,
        });

        for i in 0..self.roots.len() {
            if !self.is_managed_ptr((*self.roots[i]).as_ptr()) {
                continue;
            }

            let ptr = self.forward(ControlBlock::<StellaObject>::from_var_of_field(
                &self.roots[i],
            ));
            *self.roots[i] = ptr;
        }

        if log::log_enabled!(log::Level::Debug) {
            self.print_state();
        }
    }

    fn stop_collection(&mut self) {
        log::info!("collection ended");

        self.stats.gc_cycles_full += 1;

        self.incremental_state = None;
        swap(&mut self.from_space, &mut self.to_space);

        if log::log_enabled!(log::Level::Debug) {
            self.print_state();
        }
    }

    fn forward(&mut self, p: &mut ControlBlock<StellaObject>) -> StellaReference {
        if !self.points_to_fromspace(p.as_ptr()) {
            return p.get_value();
        }

        let object = p.get_value();
        let f1 = object.get_field(0);
        if self.points_to_tospace(f1.as_ptr()) {
            return f1;
        }

        if self.is_managed_ptr(p.as_ptr()) {
            let field_count = p.get_value().get_fields_count() as usize;
            self.transfer_object(
                p.get_value(),
                ControlBlock::<StellaObject>::from_ptr(self.next).get_value(),
                field_count,
            );

            let object_size =
                ControlBlock::<StellaObject>::get_layout(StellaObject::get_layout(field_count))
                    .size();

            let new_next = unsafe { self.next.add(object_size) };
            self.next = new_next;
        }
        *f1
    }

    fn transfer_object(
        &self,
        from: &'static mut StellaObject,
        to: &'static mut StellaObject,
        field_count: usize,
    ) {
        // copy stella header
        to.set_header(from.header);
        // copy stella object fields
        for field_idx in 0..field_count {
            let qfi = &mut to.get_field(field_idx);
            let pfi = from.get_field(field_idx);
            **qfi = *pfi;
        }
        *from.get_field(0) = to;
    }

    pub fn push_root(&mut self, object: StellaVarOrField) {
        self.roots.push(object);
    }

    pub fn pop_root(&mut self, object: StellaVarOrField) {
        if let Some(top) = self.roots.pop() {
            if top.as_ptr().addr() != object.as_ptr().addr() {
                log::error!(
                    "Tried to pop a root that does not match the top of the stack. top was: {:p}, got: {:p}",
                    *top, *object
                );
            }
        } else {
            log::error!(
                "Tried to pop a root from the empty stack. got: {:p}",
                *object
            );
        }
    }

    pub fn read_barrier(&mut self, object: *mut StellaObject, field_index: usize) {
        log::debug!("read_barrier: {}", self.stats.read_count);
        self.stats.read_count += 1;
        if !self.is_collecting() {
            return;
        }

        self.stats.barrier_triggers += 1;

        let field = ControlBlock::<StellaObject>::from_ptr(object)
            .get_value()
            .get_field(field_index);

        if !self.points_to_fromspace(*field) {
            return;
        }

        *field = self.forward(ControlBlock::<StellaObject>::from_var_of_field(&field));
    }

    pub fn write_barrier(
        &mut self,
        _object: *mut StellaObject,
        _field_index: usize,
        _contents: *mut std::ffi::c_void,
    ) {
        self.stats.write_count += 1;
        // Not needed
    }

    fn update_stats(&mut self) {
        let mut obj_count = 0;
        obj_count += self.count_objects_in_space(self.from_space, self.next);
        let space_size = Self::space_size(self.allocated_memory());
        obj_count +=
            self.count_objects_in_space(self.limit, unsafe { self.from_space.add(space_size) });
        self.stats.max_residency = std::cmp::max(self.stats.max_residency, obj_count);

        self.stats.max_residency_memory = std::cmp::max(
            self.stats.max_residency_memory,
            (space_size - (self.limit.addr() - self.next.addr())) as usize,
        );
    }

    fn count_objects_in_space(&mut self, mut from: *mut u8, to: *mut u8) -> usize {
        let mut obj_count: usize = 0;
        while from.addr() < to.addr() {
            let block = ControlBlock::<StellaObject>::from_ptr(from);
            let object = block.get_value();
            let field_count = object.get_fields_count();
            let control_block_size = ControlBlock::<StellaObject>::get_layout(
                StellaObject::get_layout(field_count as usize),
            )
            .size();
            from = unsafe { from.add(control_block_size) };
            obj_count += 1;
        }
        obj_count
    }

    pub fn print_stats(&mut self) {
        self.update_stats();
        println!(
            "
            Stats for Copying Incremental GC\n\
                                               \
            GC Cycles: full: {} (started: {})\n\
            Total memory allocation: {} bytes ({} objects)\n\
            Maximum residency: {} bytes ({} objects)\n\
            Total memory access: {} reads and {} writes\n\
            Read barrier triggers: {}",
            self.stats.gc_cycles_full,
            self.stats.gc_cycles_started,
            self.stats.total_allocated_memory,
            self.stats.total_allocations,
            self.stats.max_residency_memory,
            self.stats.max_residency,
            self.stats.read_count,
            self.stats.write_count,
            self.stats.barrier_triggers
        );
    }

    pub fn print_roots(&self) {
        println!("Roots [{}]:", self.roots.len());
        for (i, root) in self.roots.iter().enumerate() {
            println!("  [{}] {:p}", i, (*root).as_ptr());
        }
    }

    pub(crate) fn is_managed_ptr<T>(&self, p: *mut T) -> bool {
        self.points_to_fromspace(p) || self.points_to_tospace(p)
    }

    fn points_to_fromspace<T>(&self, p: *mut T) -> bool {
        self.points_to_space(p, self.from_space)
    }

    fn points_to_tospace<T>(&self, p: *mut T) -> bool {
        self.points_to_space(p, self.to_space)
    }

    fn points_to_space<T, U>(&self, p: *mut T, space_start: *mut U) -> bool {
        let start_address = space_start.addr();
        let pointer_address = p.addr();
        let end_address = space_start.addr() + Self::space_size(self.allocated_memory());
        start_address <= pointer_address && pointer_address < end_address
    }

    pub(crate) fn print_state(&mut self) {
        println!(
            "Phase: {}",
            if self.is_collecting() {
                "Collecting"
            } else {
                "Idle"
            }
        );
        println!(
            "from_space: {:p} next: {:p} to_space: {:p}",
            self.from_space, self.next, self.to_space
        );
        if self.is_collecting() {
            println!(
                "scan: {:p} limit: {:p}",
                self.incremental_state.as_ref().unwrap().scan,
                self.limit
            );
        }

        self.print_roots();

        if !self.is_collecting() {
            println!("--- GC FromSpace State ---");
            print_memory_chunks(self.from_space, self.next);
            println!("--- End of FromSpace ---");
        } else {
            println!("--- GC FromSpace State ---");
            print_memory_chunks(self.from_space, unsafe {
                self.from_space
                    .add(Self::space_size(self.allocated_memory()))
            });
            println!("--- End of FromSpace ---");

            println!("--- GC ToSpace State ---");
            print_memory_chunks(self.to_space, self.next);
            println!("--- ---");
            print_memory_chunks(*self.limit(), unsafe {
                self.to_space.add(Self::space_size(self.allocated_memory()))
            });
            println!("--- End of ToSpace ---");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_gc_state_incremental() {
        env_logger::builder()
            .is_test(true)
            .filter_level(log::LevelFilter::Trace)
            .init();

        let mut gc = GarbageCollector::new(320);
        let specs = vec![
            // 1
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(13 / 3), Some(4 / 3)],
            },
            // 4
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(10 / 3), Some(7 / 3)],
            },
            // 7
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
            // 10
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
            // 13
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(19 / 3), Some(16 / 3)],
            },
            // 16
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
            // 19
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(25 / 3), Some(22 / 3)],
            },
            // 22
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
            // 25
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
            // 28
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            },
        ];

        let mut objs = setup_test_objects(&mut gc, &specs);
        gc.push_root(ptr_ptr_to_ref_ref(unsafe { objs.as_mut_ptr().add(19 / 3) }));
        gc.push_root(ptr_ptr_to_ref_ref(unsafe { objs.as_mut_ptr().add(28 / 3) }));
        assert_eq!(gc.is_collecting(), false);
        _ = setup_test_objects(
            &mut gc,
            &vec![TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            }],
        );
        assert_eq!(gc.is_collecting(), true);
        assert_eq!(gc.scan().addr(), gc.to_space.addr() + 32 * 1);
        assert_eq!(gc.next.addr(), gc.to_space.addr() + 32 * 4);
        assert_eq!(gc.limit().addr(), gc.to_space.addr() + 32 * (10 - 1));

        _ = setup_test_objects(
            &mut gc,
            &vec![TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            }],
        );
        assert_eq!(gc.is_collecting(), true);
        assert_eq!(gc.limit().addr(), gc.to_space.addr() + 32 * (10 - 2));
        assert_eq!(gc.scan().addr(), gc.to_space.addr() + 32 * 2);
        assert_eq!(gc.next.addr(), gc.to_space.addr() + 32 * 4);

        gc.pop_root(ptr_ptr_to_ref_ref(unsafe { objs.as_mut_ptr().add(28 / 3) }));

        _ = setup_test_objects(
            &mut gc,
            &vec![
                TestObjectSpec {
                    field_count: 3,
                    field_refs: vec![None, None, None],
                },
                TestObjectSpec {
                    field_count: 3,
                    field_refs: vec![None, None, None],
                },
            ],
        );
        assert_eq!(gc.is_collecting(), false);
        assert_eq!(gc.next.addr(), gc.from_space.addr() + 32 * 4);

        _ = setup_test_objects(
            &mut gc,
            &vec![
                TestObjectSpec {
                    field_count: 3,
                    field_refs: vec![None, None, None],
                },
                TestObjectSpec {
                    field_count: 3,
                    field_refs: vec![None, None, None],
                },
            ],
        );
        assert_eq!(gc.is_collecting(), false);
        assert_eq!(gc.next.addr(), gc.from_space.addr() + 32 * 6);

        _ = setup_test_objects(
            &mut gc,
            &vec![TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            }],
        );
        gc.print_state();
        assert_eq!(gc.is_collecting(), true);
    }

    #[derive(Debug, Clone)]
    pub struct TestObjectSpec {
        pub field_count: usize,
        pub field_refs: Vec<Option<usize>>,
    }

    pub fn setup_test_objects(
        gc: &mut GarbageCollector,
        specs: &[TestObjectSpec],
    ) -> Vec<*mut StellaObject> {
        let mut ptrs = Vec::with_capacity(specs.len());

        for (i, spec) in specs.iter().enumerate() {
            let obj_ptr = gc.alloc(StellaObject::get_layout(spec.field_count).size());
            unsafe { (*obj_ptr).set_header((spec.field_count << 4 | (i * 3 + 1) << 16) as i32) }
            ptrs.push(obj_ptr);
        }

        for (i, spec) in specs.iter().enumerate() {
            for (field_idx, ref_idx_opt) in spec.field_refs.iter().enumerate() {
                if let Some(ref_idx) = ref_idx_opt {
                    unsafe {
                        (*ptrs[i]).set_field(field_idx, ptrs[*ref_idx]);
                    }
                } else {
                    unsafe {
                        (*ptrs[i]).set_field(field_idx, 0xFFFFFFFFFFFFFFFFu64 as *mut StellaObject);
                    }
                }
            }
        }

        ptrs
    }
}
