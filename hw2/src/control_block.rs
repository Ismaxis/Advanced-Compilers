use std::alloc::Layout;

use crate::types::{StellaObject, StellaReference, StellaVarOrField};

#[repr(C)]
pub struct ControlBlock {
    pub some_header: u64, // TODO:
    pub value: StellaObject,
}

impl ControlBlock {
    pub(crate) fn ptr_to_ref<T>(value: *mut T) -> &'static mut T {
        unsafe { value.as_mut::<'static>() }.unwrap()
    }

    pub fn as_ptr(&mut self) -> *mut Self {
        std::ptr::addr_of_mut!(*self)
    }

    pub fn from_ptr<T>(value: *mut T) -> &'static mut Self {
        Self::ptr_to_ref(value as *mut ControlBlock)
    }

    pub fn from_var_of_field(root: StellaVarOrField) -> &'static mut Self {
        Self::from_ptr(Self::from_value_ptr(*root))
    }

    fn from_value_ptr(value: *const StellaObject) -> *mut Self {
        let offset = std::mem::offset_of!(ControlBlock, value);
        (value as *const u8).wrapping_sub(offset) as *mut Self
    }

    pub fn control_block_layout(value_layout: Layout) -> Layout {
        let header = Self::header_layout();

        let (full_layout, _value_offset) = header.extend(value_layout).unwrap();
        full_layout
    }

    pub fn header_layout() -> Layout {
        let header = Layout::new::<u64>();
        header
    }

    pub fn get_value(&mut self) -> StellaReference {
        Self::ptr_to_ref(std::ptr::addr_of_mut!(self.value))
    }

    pub fn get_size(&mut self) -> usize {
        Self::control_block_layout(StellaObject::get_layout(
            self.value.get_fields_count() as usize
        ))
        .size()
    }
}
