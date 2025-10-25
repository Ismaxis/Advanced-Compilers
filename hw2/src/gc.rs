use std::{
    alloc::{GlobalAlloc, Layout},
    mem::swap,
};

use crate::{control_block::ControlBlock, print_memory_chunks, print_state, types::*};

#[derive(Debug, Default)]
struct GCStats {
    pub total_allocations: usize,
    pub total_allocated_memory: usize,
    pub gc_cycles: usize,
    pub max_residency: usize,
    pub max_residency_memory: usize,
    pub read_count: usize,
    pub write_count: usize,
    pub _barrier_triggers: usize,
}

pub struct GarbageCollector {
    max_alloc_size: usize,
    roots: Vec<StellaVarOrField>,
    stats: GCStats,

    pub(crate) from_space: *mut u8,
    pub(crate) to_space: *mut u8,
    pub(crate) next: *mut u8,
}

impl GarbageCollector {
    pub fn new(max_alloc_size: usize) -> Self {
        let allocated_memory = max_alloc_size * 2;
        let ptr = unsafe { std::alloc::System.alloc(Self::heap_layout(allocated_memory)) };
        log::info!("heap [{:p} : {:p}]", ptr, unsafe {
            ptr.offset(Self::space_size(allocated_memory) as isize)
        });
        GarbageCollector {
            max_alloc_size: max_alloc_size,
            roots: Vec::new(),
            stats: GCStats::default(),
            from_space: ptr,
            to_space: unsafe { ptr.offset(Self::space_size(allocated_memory) as isize) },
            next: ptr,
        }
    }

    pub fn finalize(&mut self) {
        let smallest = if self.from_space.addr() < self.to_space.addr() {
            self.from_space
        } else {
            self.to_space
        };
        unsafe { std::alloc::System.dealloc(smallest, Self::heap_layout(self.allocated_memory())) };
    }

    pub fn allocated_memory(&self) -> usize {
        self.max_alloc_size * 2
    }

    pub(crate) fn space_size(allocated_memory: usize) -> usize {
        allocated_memory / 2
    }

    fn heap_layout(allocated_memory: usize) -> Layout {
        Layout::array::<u8>(allocated_memory).unwrap()
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut StellaObject {
        log::debug!("alloc {}", size_in_bytes);
        let control_block_header_size = ControlBlock::<StellaObject>::header_layout().size();
        let requested_memory_size = control_block_header_size + size_in_bytes;

        self.stats.total_allocations += 1;
        self.stats.total_allocated_memory += requested_memory_size;

        if self.next.addr() + requested_memory_size
            > self.from_space.addr() + Self::space_size(self.allocated_memory())
        {
            if let None = self.collect() {
                self.out_of_memory();
            }
        }

        // second check, if not enough was freed
        if self.next.addr() + requested_memory_size
            > self.from_space.addr() + Self::space_size(self.allocated_memory())
        {
            self.out_of_memory();
        }

        let block = ControlBlock::<StellaObject>::from_ptr(self.next);

        let result = block.get_value().as_ptr();
        self.next = unsafe { self.next.add(requested_memory_size) };
        result
    }

    fn out_of_memory(&self) {
        log::error!("out of memory {}", self.stats.gc_cycles);
        panic!("out of memory");
    }

    pub fn collect(&mut self) -> Option<()> {
        log::info!("collection started");
        if log::log_enabled!(log::Level::Debug) {
            print_state();
        }

        self.stats.gc_cycles += 1;
        self.next = self.to_space;
        let mut scan = self.next;

        log::trace!("scanning roots [{}]", self.roots.len());
        for i in 0..self.roots.len() {
            log::trace!("scan root {:p} -> {:p}", self.roots[i], *self.roots[i]);
            if !self.is_managed_ptr((*self.roots[i]).as_ptr()) {
                log::warn!(
                    "skipping root that points to not managed memory {:p}",
                    *self.roots[i]
                );
                continue;
            }

            let ptr = self.forward(ControlBlock::<StellaObject>::from_var_of_field(
                &self.roots[i],
            ))?;
            *self.roots[i] = ptr;
            log::trace!("root scanned {:p} -> {:p}", self.roots[i], *self.roots[i]);
            log::trace!("");
        }

        while scan.addr() < self.next.addr() {
            let block = ControlBlock::<StellaObject>::from_ptr(scan);
            let object = block.get_value();
            let field_count = object.get_fields_count();

            for field_idx in 0..field_count as usize {
                let field = &mut object.get_field(field_idx);
                if self.is_managed_ptr(**field) {
                    **field =
                        self.forward(ControlBlock::<StellaObject>::from_var_of_field(field))?;
                }
            }

            let control_block_size = ControlBlock::<StellaObject>::get_layout(
                StellaObject::get_layout(object.get_fields_count() as usize),
            )
            .size();
            scan = unsafe { scan.add(control_block_size) }
        }

        swap(&mut self.from_space, &mut self.to_space);

        // TODO: remove
        unsafe {
            std::ptr::write_bytes(self.to_space, 0, Self::space_size(self.allocated_memory()));
        }

        log::info!("collection ended");
        if log::log_enabled!(log::Level::Debug) {
            print_state();
        }

        self.update_stats();

        Some(())
    }

    fn update_stats(&mut self) {
        let mut obj_count = 0;
        let mut ptr = self.to_space;
        while ptr.addr() < self.next.addr() {
            let block = ControlBlock::<StellaObject>::from_ptr(ptr);
            let object = block.get_value();
            let field_count = object.get_fields_count();
            let control_block_size = ControlBlock::<StellaObject>::get_layout(
                StellaObject::get_layout(field_count as usize),
            )
            .size();
            ptr = unsafe { ptr.add(control_block_size) };
            obj_count += 1;
        }
        self.stats.max_residency = std::cmp::max(self.stats.max_residency, obj_count);

        self.stats.max_residency_memory = std::cmp::max(
            self.stats.max_residency_memory,
            (self.next.addr() as isize - self.to_space.addr() as isize) as usize,
        );
    }

    fn forward(&mut self, p: &mut ControlBlock<StellaObject>) -> Option<StellaReference> {
        log::trace!("forward block {:p}", p.as_ptr());
        if !self.points_to_fromspace(p.as_ptr()) {
            log::trace!("not from fromspace {:p}", p.as_ptr());
            return Some(p.get_value());
        }
        log::trace!("from fromspace {:p}", p.as_ptr());

        let object = p.get_value();
        let f1 = object.get_field(0);
        log::trace!("first field of block {:p}: {:p}", p.as_ptr(), f1.as_ptr());
        if self.points_to_tospace(f1.as_ptr()) {
            log::trace!(
                "first field from tospace {:p}: {:p}",
                p.as_ptr(),
                f1.as_ptr()
            );
            return Some(*f1);
        }
        log::trace!(
            "first field not from tospace {:p}: {:p}",
            p.as_ptr(),
            f1.as_ptr()
        );

        if self.is_managed_ptr(p.as_ptr()) {
            self.chase(p)?;
        }
        return Some(*f1);
    }

    fn chase(&mut self, mut p: &mut ControlBlock<StellaObject>) -> Option<()> {
        log::trace!("chase iter {:p}", p.as_ptr());
        loop {
            log::trace!("chase moving to {:p}", self.next);
            let q = ControlBlock::<StellaObject>::from_ptr(self.next);
            let control_block_size = ControlBlock::<StellaObject>::get_layout(
                StellaObject::get_layout(p.get_value().get_fields_count() as usize),
            )
            .size();
            self.next = unsafe { self.next.add(control_block_size) };
            log::trace!("new next {:p}", self.next);
            if !self.is_managed_ptr(self.next) {
                log::warn!(
                    "out of memory {:p}, [{:p}, {:p}]",
                    self.next,
                    self.from_space,
                    self.to_space
                );
                return None;
            }
            log::debug!(
                "space left: {}",
                self.to_space.addr() + Self::space_size(self.allocated_memory()) - self.next.addr()
            );

            let mut r: Option<&mut ControlBlock<StellaObject>> = None;
            let p_object = p.get_value();
            let q_object = q.get_value();
            let field_count = p_object.get_fields_count();
            log::trace!("field count {}", field_count);

            if log::log_enabled!(log::Level::Trace) {
                log::trace!("== BEFORE ==");
                print_memory_chunks(self.from_space as *const u8, unsafe {
                    (self.from_space as *const u8).add(Self::space_size(self.allocated_memory()))
                });
                log::trace!("");
                print_memory_chunks(self.to_space as *const u8, self.next as *const u8);
            }

            // copy stella header
            q_object.set_header(p_object.header);
            // copy stella object fields
            for field_idx in 0..field_count as usize {
                let qfi = &mut q_object.get_field(field_idx);
                let pfi = p_object.get_field(field_idx);
                **qfi = *pfi;

                if self.points_to_fromspace((*qfi).as_ptr())
                    && !self.points_to_tospace((*(*qfi).get_field(0)).as_ptr())
                {
                    r = Some(ControlBlock::<StellaObject>::from_var_of_field(qfi));
                }
            }

            *p_object.get_field(0) = q_object;

            if log::log_enabled!(log::Level::Trace) {
                log::trace!("== AFTER ==");
                print_memory_chunks(self.from_space as *const u8, unsafe {
                    (self.from_space as *const u8).add(Self::space_size(self.allocated_memory()))
                });
                log::trace!("");
                print_memory_chunks(self.to_space as *const u8, self.next as *const u8);
            }
            if let Some(t) = r {
                p = t;
            } else {
                break;
            }
        }
        Some(())
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

    pub fn read_barrier(&mut self, _object: *mut StellaObject, _field_index: usize) {
        self.stats.read_count += 1;
        // Not needed
    }

    pub fn write_barrier(
        &mut self,
        _object: *mut StellaObject,
        _field_index: usize,
        _contents: *mut std::ffi::c_void,
    ) {
        self.stats.write_count += 1;
        // TODO: Implement write barrier logic here
    }

    pub fn print_stats(&self) {
        println!(
            "MAX_ALLOC_SIZE: {}\n\
            GC Cycles: {}\n\
            Total memory allocation: {} bytes ({} objects)\n\
            Maximum residency: {} bytes ({} objects)\n\
            Total memory use: {} reads and {} writes",
            self.max_alloc_size,
            self.stats.gc_cycles,
            self.stats.total_allocated_memory,
            self.stats.total_allocations,
            self.stats.max_residency_memory,
            self.stats.max_residency,
            self.stats.read_count,
            self.stats.write_count
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
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_gc_state_from_hw1() {
        env_logger::builder()
            .is_test(true)
            .filter_level(log::LevelFilter::Trace)
            .init();

        let mut gc = GarbageCollector::new(320);
        let specs = vec![
            // 1
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, Some(7 / 3)],
            },
            // 4
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(19 / 3), None],
            },
            // 7
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, Some(13 / 3)],
            },
            // 10
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(16 / 3), None],
            },
            // 13
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(10 / 3), Some(16 / 3)],
            },
            // 16
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(7 / 3), Some(25 / 3)],
            },
            // 19
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(4 / 3), Some(22 / 3)],
            },
            // 22
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, Some(19 / 3), Some(4 / 3)],
            },
            // 25
            TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, Some(1 / 3)],
            },
        ];

        let mut objs = setup_test_objects(&mut gc, &specs);
        gc.push_root(ptr_ptr_to_ref_ref(unsafe { objs.as_mut_ptr().add(3) }));
        assert_eq!((gc.next.addr() - gc.from_space.addr()) / 32, 9);
        _ = setup_test_objects(
            &mut gc,
            &vec![TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            }],
        );
        assert_eq!((gc.next.addr() - gc.from_space.addr()) / 32, 10);
        _ = setup_test_objects(
            &mut gc,
            &vec![TestObjectSpec {
                field_count: 3,
                field_refs: vec![None, None, None],
            }],
        );
        gc.print_stats();
        assert_eq!((gc.next.addr() - gc.from_space.addr()) / 32, 6 + 1);
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
                        (*ptrs[i]).set_field(field_idx, 0xBAADF00DDEADBEEFu64 as *mut StellaObject);
                    }
                }
            }
        }

        ptrs
    }
}
