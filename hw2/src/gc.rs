use std::ptr::null_mut;

pub struct GcObject {
    pub header: usize,
    pub fields: Vec<*mut GcObject>,
}

pub struct GarbageCollector {
    roots: Vec<*mut *mut GcObject>,
}

impl GarbageCollector {
    pub fn new() -> Self {
        GarbageCollector { roots: Vec::new() }
    }

    pub fn alloc(&mut self, size_in_bytes: usize) -> *mut GcObject {
        let obj = GcObject {
            header: 0, // Initialize header as needed
            fields: vec![null_mut(); size_in_bytes / std::mem::size_of::<*mut GcObject>()],
        };
        let obj_ptr = Box::into_raw(Box::new(obj));
        obj_ptr
    }

    pub fn collect(&mut self) {
        // Implement garbage collection logic here
    }

    pub fn push_root(&mut self, object: *mut *mut GcObject) {
        self.roots.push(object);
    }

    pub fn pop_root(&mut self, object: *mut *mut GcObject) {
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

    pub fn read_barrier(&self, _object: *mut GcObject, _field_index: usize) {
        // Implement read barrier logic here
    }

    pub fn write_barrier(
        &self,
        _object: *mut GcObject,
        _field_index: usize,
        _contents: *mut std::ffi::c_void,
    ) {
        // Implement write barrier logic here
    }

    pub fn print_stats(&self) {
        // Implement statistics printing logic here
    }
}
