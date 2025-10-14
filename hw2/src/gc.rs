use std::ptr::null_mut;

pub struct StellaObject {
    pub header: usize,
    pub fields: Vec<*mut StellaObject>,
}

pub struct GarbageCollector {
    roots: Vec<*mut *mut StellaObject>,
}

impl GarbageCollector {
    pub fn new() -> Self {
        GarbageCollector { roots: Vec::new() }
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut StellaObject {
        let obj = StellaObject {
            header: 0,
            fields: vec![null_mut(); size_in_bytes / std::mem::size_of::<*mut StellaObject>()],
        };
        let obj_ptr = Box::into_raw(Box::new(obj));
        obj_ptr
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

    pub fn read_barrier(&self, _object: *mut StellaObject, _field_index: usize) {
        // Implement read barrier logic here
    }

    pub fn write_barrier(
        &self,
        _object: *mut StellaObject,
        _field_index: usize,
        _contents: *mut std::ffi::c_void,
    ) {
        // Implement write barrier logic here
    }

    pub fn print_stats(&self) {
        // Implement statistics printing logic here
    }
}
