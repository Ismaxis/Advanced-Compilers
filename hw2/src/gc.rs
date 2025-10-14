use std::{
    alloc::{GlobalAlloc, Layout},
    ptr::null_mut,
};

use crate::{control_block::ControlBlock, types::*};

#[derive(Debug, Default)]
struct GCStats {
    pub total_allocations: usize,
    pub total_allocated_memory: usize,
    pub gc_cycles: usize,
    pub _max_residency: usize,
    pub _max_residency_memory: usize,
    pub read_count: usize,
    pub write_count: usize,
    pub _barrier_triggers: usize,
}

pub struct GarbageCollector {
    roots: Vec<RootReference>,
    stats: GCStats,

    pub(crate) from_space: *mut u8,
    pub(crate) to_space: *mut u8,
    pub(crate) next: *mut u8,
}

impl GarbageCollector {
    pub fn new() -> Self {
        let ptr = unsafe { std::alloc::System.alloc(Self::heap_layout()) };
        log::info!("heap start: {:p}", ptr);
        GarbageCollector {
            roots: Vec::new(),
            stats: GCStats::default(),
            from_space: ptr,
            to_space: unsafe { ptr.offset(Self::SPACE_SIZE as isize) },
            next: ptr,
        }
    }

    pub fn finalize(&mut self) {
        unsafe { std::alloc::System.dealloc(self.from_space, Self::heap_layout()) };
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut StellaObject {
        let control_block_header = ControlBlock::<StellaObject>::header_layout();
        let allocated_memory = control_block_header.size() + size_in_bytes;

        self.stats.total_allocations += 1;
        self.stats.total_allocated_memory += allocated_memory;

        if self.next.addr() + allocated_memory > self.from_space.addr() + Self::SPACE_SIZE {
            if let None = self.collect() {
                panic!("out of memory");
            }
        }

        {
            // TODO: remove
            let block = self.next as *mut ControlBlock<*mut StellaObject>;
            unsafe {
                // (*block).some_header = 0xBAAD_F00D_DEAD_BEEFu64;
                (*block).some_header = 0xFFFF_FFFF_FFFF_FFFFu64;
            }
        }

        let result = StellaObject::from_ptr(unsafe {
            self.next.offset(control_block_header.size() as isize)
        });

        self.next = unsafe { self.next.offset(allocated_memory as isize) };

        result
    }

    const MAX_ALLOC_SIZE: usize = 512;
    const SPACE_SIZE: usize = Self::MAX_ALLOC_SIZE / 2;
    fn heap_layout() -> Layout {
        Layout::array::<usize>(Self::MAX_ALLOC_SIZE).unwrap()
    }

    pub fn collect(&mut self) -> Option<()> {
        log::info!("collect started");

        crate::print_state();

        self.stats.gc_cycles += 1;

        self.next = self.to_space;
        let mut scan = self.next;

        log::trace!("scanning roots [{}]", self.roots.len());
        for r in self.roots.iter().cloned().collect::<Vec<_>>() {
            log::trace!("scann root {:p}", r);
            unsafe {
                let forwarded = self.forward(*r);
                *r = forwarded;
            }
        }

        while scan.addr() < self.next.addr() {
            let block = ControlBlock::from_value_ptr(StellaObject::from_ptr(scan));
            let object = unsafe { (*block).get_value() };
            let field_count = StellaObject::get_fields_count_ptr(object);

            for field_idx in 0..field_count as usize {
                let field = StellaObject::get_field_ptr(object, field_idx);
                unsafe {
                    let forwarded = self.forward(*field);
                    *field = forwarded;
                }
            }
            scan = unsafe {
                scan.add(
                    ControlBlock::<StellaObject>::control_block_layout(StellaObject::get_layout(
                        field_count as usize,
                    ))
                    .size(),
                )
            }
        }

        Some(())
    }

    fn points_to_fromspace(&self, p: *mut StellaObject) -> bool {
        Self::points_to_space(p, self.from_space as *mut StellaObject)
    }

    fn points_to_tospace(&self, p: *mut StellaObject) -> bool {
        Self::points_to_space(p, self.to_space as *mut StellaObject)
    }

    fn points_to_space(p: *mut StellaObject, space_start: *mut StellaObject) -> bool {
        space_start.addr() <= p.addr() && p.addr() < space_start.addr() + Self::SPACE_SIZE
    }

    fn forward(&mut self, p: *mut StellaObject) -> *mut StellaObject { // TODO: make control block
        log::trace!("forwarding {:p}", p);
        if !self.points_to_fromspace(p) {
            log::trace!("not from fromspace {:p}", p);
            return p;
        }
        log::trace!("from fromspace {:p}", p);

        let field0 = unsafe { *StellaObject::get_field_ptr(p, 0) };
        log::trace!("field0 from tospace {:p} {:p}", p, field0);
        if self.points_to_tospace(field0) {
            log::trace!("field0 from tospace");
            return field0;
        }
        log::trace!("field0 not from tospace");

        self.chase(p);

        return field0;
    }

    fn chase(&mut self, mut p: *mut StellaObject) { // TODO: make control block
        while !p.is_null() {
            let q = self.next as *mut StellaObject;
            log::trace!("chase iter {:p}", q);
            self.next = unsafe {
                self.next.add(
                    // TODO: not sure
                    StellaObject::get_layout(StellaObject::get_fields_count_ptr(p) as usize).size(),
                )
            };
            log::trace!("new next {:p}", self.next);
            
            let mut r: *mut StellaObject = null_mut();
            let field_count = StellaObject::get_fields_count_ptr(p);
            
            log::trace!("field count {}", field_count);
            for field_idx in 0..field_count as usize {
                let qfi = StellaObject::get_field_ptr(q, field_idx);
                log::trace!("qf {} {:x} {:p}", field_idx, qfi as usize, qfi);
                unsafe { *qfi = *StellaObject::get_field_ptr(p, field_idx) }
                log::trace!("wrote qf {} {:p}", field_idx, qfi);

                if self.points_to_fromspace(unsafe { *qfi })
                    && !self.points_to_tospace(unsafe { *StellaObject::get_field_ptr(*qfi, 0) })
                {
                    r = unsafe { *qfi };
                }
            }

            unsafe { *StellaObject::get_field_ptr(q, 0) = q };
            p = r;
        }
    }

    pub fn push_root(&mut self, object: *mut *mut StellaObject) {
        self.roots.push(object);
    }

    pub fn pop_root(&mut self, object: *mut *mut StellaObject) {
        if let Some(top) = self.roots.pop() {
            if top != object {
                log::error!("Tried to pop a root that does not match the top of the stack. top was: {:p}, got: {:p}", top, object);
            }
        } else {
            log::error!(
                "Tried to pop a root from the empty stack. got: {:p}",
                object
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
        // They are needed to track references from older generations to younger ones.
        // Without write barriers, the collector may miss live objects in the young generation that
        // are only reachable from the old generation, leading to incorrect collection (premature deallocation).
    }

    pub fn print_stats(&self) {
        println!(
            "Total memory allocation: {} bytes ({} objects)\n\
            Maximum residency: {} bytes ({} objects)\n\
            Total memory use: {} reads and {} writes",
            self.stats.total_allocated_memory,
            self.stats.total_allocations,
            "TODO", // self.stats.max_residency_memory,
            "TODO", // self.stats.max_residency,
            self.stats.read_count,
            self.stats.write_count
        );
    }
}
