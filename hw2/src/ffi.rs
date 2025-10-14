use std::ffi::{c_int, c_void};

use crate::gc;

#[no_mangle]
pub extern "C" fn gc_alloc(size_in_bytes: usize) -> *mut c_void {
    return crate::alloc(size_in_bytes) as *mut c_void;
}

#[no_mangle]
pub extern "C" fn gc_read_barrier(object: *mut c_void, field_index: c_int) {
    crate::read_barrier(object as *mut gc::GcObject, field_index as usize);
}

#[no_mangle]
pub extern "C" fn gc_write_barrier(object: *mut c_void, field_index: c_int, contents: *mut c_void) {
    crate::write_barrier(object as *mut gc::GcObject, field_index as usize, contents);
}

#[no_mangle]
pub extern "C" fn gc_push_root(object: *mut *mut c_void) {
    crate::push_root(object as *mut *mut gc::GcObject);
}

#[no_mangle]
pub extern "C" fn gc_pop_root(object: *mut *mut c_void) {
    crate::pop_root(object as *mut *mut gc::GcObject);
}

#[no_mangle]
pub extern "C" fn print_gc_alloc_stats() {
    crate::print_alloc_stats();
}

#[no_mangle]
pub extern "C" fn print_gc_state() {
    crate::print_state();
}

#[no_mangle]
pub extern "C" fn print_gc_roots() {
    crate::print_roots();
}
