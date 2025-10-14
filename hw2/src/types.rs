#[repr(C)]
pub struct StellaObject {
    pub object_header: i32,
    pub object_fields: *mut *mut std::ffi::c_void,
}

#[repr(C)]
pub struct GCStats {
    pub total_allocated_memory: usize,
    pub max_residency: usize,
    pub memory_usage: usize,
    pub barrier_triggers: usize,
    pub gc_cycles: usize,
}

pub type RootReference = *mut *mut std::ffi::c_void;
