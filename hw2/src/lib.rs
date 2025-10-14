pub mod ffi;
pub mod gc;
pub mod types;

use ctor::ctor;

#[ctor]
fn init() {
    let err = env_logger::try_init();
    if let Err(err) = err {
        println!("unable to init logger for GC: {}", err.to_string())
    }

    init_gc();
}

static mut GC_INSTANCE: Option<gc::GarbageCollector> = None;

pub fn init_gc() {
    unsafe {
        GC_INSTANCE = Some(gc::GarbageCollector::new());
    }
}

fn get_gc() -> &'static mut gc::GarbageCollector {
    unsafe {
        #[allow(static_mut_refs)]
        GC_INSTANCE.as_mut().expect("GC not initialized")
    }
}

#[no_mangle]
pub(crate) fn alloc(size_in_bytes: usize) -> *mut gc::GcObject {
    log::debug!("alloc: {}", size_in_bytes);
    return get_gc().alloc(size_in_bytes);
}

#[no_mangle]
pub(crate) fn read_barrier(object: &mut gc::GcObject, field_index: i32) {
    log::debug!(
        "read_barrier: object_addr={:p}, field_index={}",
        object,
        field_index
    );
    // todo!();
}

#[no_mangle]
pub(crate) fn write_barrier(object: &mut gc::GcObject, field_index: i32, contents: &mut gc::GcObject) {
    log::debug!(
        "write_barrier: object={:p}, field_index={}, contents={:p}",
        object,
        field_index,
        contents
    );
    // todo!();
}

#[no_mangle]
pub(crate) fn push_root(object: &mut &mut gc::GcObject) {
    log::debug!("push_root: object={:p}", object);
    // todo!();
}

#[no_mangle]
pub(crate) fn pop_root(object: &mut &mut gc::GcObject) {
    log::debug!("pop_root: object={:p}", object);
    // todo!();
}

#[no_mangle]
pub(crate) fn print_alloc_stats() {
    log::debug!("print_alloc_stats");
    // todo!();
}

#[no_mangle]
pub(crate) fn print_state() {
    log::debug!("print_state");
    // todo!();
}

#[no_mangle]
pub(crate) fn print_roots() {
    log::debug!("print_roots");
    // todo!();
}
