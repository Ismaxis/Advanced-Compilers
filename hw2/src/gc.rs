use std::alloc::{GlobalAlloc, Layout};

use crate::{control_block::ControlBlock, types::*};

#[derive(Debug, Default)]
struct GCStats {
    pub total_allocations: usize,
    pub total_allocated_memory: usize,
    pub gc_cycles: usize,
    pub max_residency: usize,
    pub max_residency_memory: usize,
    pub read_count: usize,
    pub write_count: usize,
    pub barrier_triggers: usize,
}

pub struct GarbageCollector {
    roots: Vec<RootReference>,
    stats: GCStats,

    pub(crate) heap: *mut u8,
    pub(crate) free: *mut u8,
}

impl GarbageCollector {
    pub fn new() -> Self {
        let ptr = unsafe { std::alloc::System.alloc(Self::heap_layout()) };
        log::info!("heap start: {:p}", ptr);
        GarbageCollector {
            roots: Vec::new(),
            stats: GCStats::default(),
            heap: ptr,
            free: ptr,
        }
    }

    pub fn finalize(&mut self) {
        unsafe { std::alloc::System.dealloc(self.heap, Self::heap_layout()) };
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut StellaObject {
        let control_block_header = ControlBlock::<StellaObject>::header_layout();
        let result =
            unsafe { self.free.offset(control_block_header.size() as isize) } as *mut StellaObject;
        {
            let block = self.free as *mut ControlBlock<*mut StellaObject>;
            unsafe {
                (*block).some_header = 0xBAAD_F00D_DEAD_BEEFu64;
            }
        }

        let allocated_memory = control_block_header.size() + size_in_bytes;

        self.stats.total_allocations += 1;
        self.stats.total_allocated_memory += allocated_memory;

        if self.free.addr() + allocated_memory > self.heap.addr() + Self::MAX_ALLOC_SIZE {
            panic!("out of memory");
        }

        self.free = unsafe { self.free.offset((allocated_memory) as isize) };

        result
    }

    const MAX_ALLOC_SIZE: usize = 512;
    fn heap_layout() -> Layout {
        Layout::array::<usize>(Self::MAX_ALLOC_SIZE).unwrap()
    }

    pub fn collect(&mut self) {
        self.stats.gc_cycles += 1;
        // Implement garbage collection logic here
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
