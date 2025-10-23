mod control_block;
pub mod ffi;
pub mod gc;
pub mod types;

use ctor::{ctor, dtor};

use crate::control_block::ControlBlock;
use crate::types::*;

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

static mut GC_INSTANCE: Option<gc::GarbageCollector> = None;

pub fn init_gc() {
    unsafe {
        GC_INSTANCE = Some(gc::GarbageCollector::new(crate::ffi::STELLA_MAX_ALLOC_SIZE));
    }
}

fn get_gc() -> &'static mut gc::GarbageCollector {
    unsafe {
        #[allow(static_mut_refs)]
        GC_INSTANCE.as_mut().expect("GC not initialized")
    }
}

#[no_mangle]
pub(crate) fn alloc(size_in_bytes: usize) -> *mut StellaObject {
    // print_state();
    let allocated = get_gc().alloc(size_in_bytes);
    log::info!("alloc: {} => {:p}", size_in_bytes, allocated);
    allocated
}

#[no_mangle]
pub(crate) fn read_barrier(object: *mut StellaObject, field_index: usize) {
    // log::debug!(
    //     "read_barrier: object_addr={:p}, field_index={}",
    //     object,
    //     field_index
    // );
    get_gc().read_barrier(object, field_index);
}

#[no_mangle]
pub(crate) fn write_barrier(
    object: *mut StellaObject,
    field_index: usize,
    contents: *mut std::ffi::c_void,
) {
    // log::debug!(
    //     "write_barrier: object={:p}, field_index={}, contents={:p}",
    //     object,
    //     field_index,
    //     contents
    // );
    get_gc().write_barrier(object, field_index, contents);
}

#[no_mangle]
pub(crate) fn push_root(object: *mut *mut StellaObject) {
    log::debug!("push_root: object={:p} to={:p}", object, unsafe { *object });
    get_gc().push_root(StellaVarOrField::from_reference(object));
}

#[no_mangle]
pub(crate) fn pop_root(object: *mut *mut StellaObject) {
    log::debug!("pop_root: object={:p} to={:p}", object, unsafe { *object });
    get_gc().pop_root(StellaVarOrField::from_reference(object));
}

#[no_mangle]
pub(crate) fn print_alloc_stats() {
    log::debug!("print_alloc_stats");
    get_gc().print_stats();
}

#[no_mangle]
pub(crate) fn print_state() {
    log::debug!("print_state");
    let gc = get_gc();

    println!(
        "from_space: {:p} next: {:p} to_space: {:p}",
        gc.from_space, gc.next, gc.to_space
    );

    gc.print_roots();

    let raw_end = unsafe {
        gc.from_space
            .add(gc::GarbageCollector::space_size(gc.max_alloc_size()))
    };
    println!("Raw memory (heap..free) in 8-byte chunks:");
    print_memory_chunks(gc.from_space, raw_end);

    println!("--- GC FromSpace State ---");
    print_heap_objects(gc.from_space, raw_end);
    println!("--- End of FromSpace ---");
    // println!("--- GC ToSpace State ---");
    // print_memory_chunks(gc.to_space, unsafe {
    //     gc.to_space.add(gc::GarbageCollector::SPACE_SIZE)
    // });
    // println!("--- End of ToSpace ---");
}

fn print_heap_objects(mut ptr: *mut u8, end: *mut u8) {
    while ptr < end {
        let block = ptr as *const ControlBlock;
        let header = 0; //unsafe { (*block).some_header };
        let value = unsafe { &(*block).value };
        let field_count = value.get_fields_count();

        print!("@{:p} [{:x}]", ptr, header);

        print_object_info(value);
        println!();

        // Advance ptr to next object
        let obj_layout = StellaObject::get_layout(field_count as usize);
        let block_layout = ControlBlock::header_layout();
        let obj_size = block_layout.size() + obj_layout.size();
        ptr = unsafe { ptr.add(obj_size) };
    }
}

pub(crate) fn print_memory_chunks(mut raw_ptr: *const u8, raw_end: *const u8) {
    while raw_ptr < raw_end {
        // if log::log_enabled!(log::Level::Debug) {
        let mut line = format!("{:p}: ", raw_ptr);
        for i in 0..8 {
            if unsafe { raw_ptr.add(i) } < raw_end {
                line.push_str(&format!("{:02x} ", unsafe { *raw_ptr.add(i) }));
            } else {
                line.push_str("   ");
            }
        }
        log::trace!("{}", line);
        // }
        raw_ptr = unsafe { raw_ptr.add(8) };
    }
}

fn print_object_info(value: &StellaObject) {
    let gc = get_gc();
    let field_count = value.get_fields_count();
    print!(" | @{:p} {:?} {}", value, value.get_tag(), field_count);

    // Print fields (if any)
    if field_count > 0 {
        print!(" | ");
        for i in 0..field_count as usize {
            let field_ptr = value.get_field(i);
            if gc.is_controller_ptr(field_ptr.as_ptr()) {
                print!("{:p} ", *field_ptr);
            } else {
                print!("0xXXXXXXXXXXXX ");
            }
        }
    }
}

#[no_mangle]
pub(crate) fn print_roots() {
    log::debug!("print_roots");
    todo!("print_roots");
}

#[dtor]
fn finalize_gc() {
    log::debug!("GC finalizing!");
    get_gc().finalize();
}
