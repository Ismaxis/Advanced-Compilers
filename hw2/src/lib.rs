mod control_block;
pub mod ffi;
pub mod gc;
pub mod types;

use ctor::{ctor, dtor};

use crate::{gc::GarbageCollector, types::*};

#[ctor]
fn init() {
    if !cfg!(test) {
        let err = env_logger::try_init();
        if let Err(err) = err {
            println!("unable to init logger for GC: {}", err.to_string())
        }
    }

    log::debug!("GC initializing!");
    init_gc();
}

#[dtor]
fn finalize_gc() {
    log::debug!("GC finalizing!");
    get_gc().finalize();
}

static mut GC_INSTANCE: Option<GarbageCollector> = None;

fn init_gc() {
    unsafe {
        let max_alloc_size = crate::ffi::STELLA_MAX_ALLOC_SIZE;
        log::info!("Initializing GC with max alloc size {}", max_alloc_size);
        GC_INSTANCE = Some(GarbageCollector::new(max_alloc_size));
    }
}

fn get_gc() -> &'static mut GarbageCollector {
    unsafe {
        #[allow(static_mut_refs)]
        GC_INSTANCE.as_mut().expect("GC not initialized")
    }
}

// === GC API ===

#[no_mangle]
pub(crate) fn alloc(size_in_bytes: usize) -> *mut StellaObject {
    let allocated = get_gc().alloc(size_in_bytes);
    log::debug!("alloc: {} => {:p}", size_in_bytes, allocated);
    allocated
}

#[no_mangle]
pub(crate) fn read_barrier(object: *mut StellaObject, field_index: usize) {
    log::debug!(
        "read_barrier: object_addr={:p}, field_index={}",
        object,
        field_index
    );
    get_gc().read_barrier(object, field_index);
}

#[no_mangle]
pub(crate) fn write_barrier(
    object: *mut StellaObject,
    field_index: usize,
    contents: *mut std::ffi::c_void,
) {
    log::debug!(
        "write_barrier: object={:p}, field_index={}, contents={:p}",
        object,
        field_index,
        contents
    );
    get_gc().write_barrier(object, field_index, contents);
}

#[no_mangle]
pub(crate) fn push_root(object: *mut *mut StellaObject) {
    log::debug!("push_root: object={:p} to={:p}", object, unsafe { *object });
    get_gc().push_root(ptr_ptr_to_ref_ref(object));
}

#[no_mangle]
pub(crate) fn pop_root(object: *mut *mut StellaObject) {
    log::debug!("pop_root: object={:p} to={:p}", object, unsafe { *object });
    get_gc().pop_root(ptr_ptr_to_ref_ref(object));
}

// === STATS API ===

#[no_mangle]
pub(crate) fn print_alloc_stats() {
    log::debug!("print_alloc_stats");
    get_gc().print_stats();
}

#[no_mangle]
pub(crate) fn print_state() {
    log::debug!("print_state");
    get_gc().print_state();
}

#[no_mangle]
pub(crate) fn print_roots() {
    log::debug!("print_roots");
    get_gc().print_roots();
}
