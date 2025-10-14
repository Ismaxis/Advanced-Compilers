use std::ffi::{c_int, c_void};

#[no_mangle]
pub extern "C" fn gc_alloc(size_in_bytes: usize) -> *mut c_void {
    log::debug!("gc_alloc: {}", size_in_bytes);

    let object = crate::alloc(size_in_bytes);
    return object as *mut c_void;
}

#[no_mangle]
pub extern "C" fn gc_read_barrier(object: *mut c_void, field_index: c_int) {
    log::debug!("gc_read_barrier: object={:?}, field_index={}", object, field_index);
    // todo!();
}

#[no_mangle]
pub extern "C" fn gc_write_barrier(object: *mut c_void, field_index: c_int, contents: *mut c_void) {
    log::debug!(
        "gc_write_barrier: object={:?}, field_index={}, contents={:?}",
        object, field_index, contents
    );
    // todo!();
}

#[no_mangle]
pub extern "C" fn gc_push_root(object: *mut *mut c_void) {
    log::debug!("gc_push_root: object={:?}", object);
    // todo!();
}

#[no_mangle]
pub extern "C" fn gc_pop_root(object: *mut *mut c_void) {
    log::debug!("gc_pop_root: object={:?}", object);
    // todo!();
}

#[no_mangle]
pub extern "C" fn print_gc_alloc_stats() {
    log::debug!("print_gc_alloc_stats");
    // todo!();
}

#[no_mangle]
pub extern "C" fn print_gc_state() {
    log::debug!("print_gc_state");
    // todo!();
}

#[no_mangle]
pub extern "C" fn print_gc_roots() {
    log::debug!("print_gc_roots");
    // todo!();
}
