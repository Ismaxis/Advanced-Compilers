use std::alloc::{GlobalAlloc, Layout};

use crate::{control_block::ControlBlock, types::*};


pub struct GarbageCollector {
    roots: Vec<*mut *mut StellaObject>,
    pub(crate) heap: *mut u8,
    pub(crate) free: *mut u8,
}

impl GarbageCollector {
    pub fn new() -> Self {
        let ptr = unsafe { std::alloc::System.alloc(Self::heap_layout()) };
        log::info!("heap start: {:p}", ptr);
        GarbageCollector {
            roots: Vec::new(),
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
        self.free = unsafe {
            self.free
                .offset((control_block_header.size() + size_in_bytes) as isize)
        };

        if self.free.addr() > self.heap.addr() + Self::MAX_ALLOC_SIZE {
            panic!("out of memory");
        }

        result
    }

    const MAX_ALLOC_SIZE: usize = 512;
    fn heap_layout() -> Layout {
        Layout::array::<usize>(Self::MAX_ALLOC_SIZE).unwrap()
    }

    pub fn collect(&mut self) {
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

    // pub fn read_barrier(&self, _object: *mut StellaObject, _field_index: usize) {
    //     // Not needed
    // }

    pub fn write_barrier(
        &self,
        _object: *mut StellaObject,
        _field_index: usize,
        _contents: *mut std::ffi::c_void,
    ) {
        // TODO: Implement write barrier logic here
        // They are needed to track references from older generations to younger ones.
        // Without write barriers, the collector may miss live objects in the young generation that
        // are only reachable from the old generation, leading to incorrect collection (premature deallocation).
    }

    pub fn print_stats(&self) {
        // Implement statistics printing logic here
    }
}
