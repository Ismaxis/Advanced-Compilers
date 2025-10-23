use std::{
    alloc::Layout,
    ops::{Deref, DerefMut},
};

use c_enum::c_enum;

c_enum! {
    #[derive(Copy, Clone, PartialEq, Eq, Hash)]
    pub enum StellaTag: i32 {
        TAG_ZERO,
        TAG_SUCC,
        TAG_FALSE,
        TAG_TRUE,
        TAG_FN,
        TAG_REF,
        TAG_UNIT,
        TAG_TUPLE,
        TAG_INL,
        TAG_INR,
        TAG_EMPTY,
        TAG_CONS,
    }
}

pub type StellaReference = &'static StellaObject;

#[derive(Copy, Clone, PartialEq, Eq, Hash)]
pub struct StellaVarOrField(pub *mut StellaReference);

impl StellaVarOrField {
    pub fn write(&mut self, ptr: StellaReference) {
        unsafe {
            *self.0 = ptr;
        }
    }

    pub fn from_reference(object: *mut *mut StellaObject) -> StellaVarOrField {
        let ptr_to_ref =
            unsafe { std::mem::transmute::<*mut *mut StellaObject, *mut StellaReference>(object) };
        StellaVarOrField(ptr_to_ref)
    }
}

impl Deref for StellaVarOrField {
    type Target = StellaReference;

    fn deref(&self) -> &Self::Target {
        unsafe { &*self.0 }
    }
}

impl DerefMut for StellaVarOrField {
    fn deref_mut(&mut self) -> &mut Self::Target {
        unsafe { &mut *self.0 }
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct StellaObject {
    pub header: i32,
    pub fields: StellaReference,
}

impl StellaObject {
    const FIELD_COUNT_MASK: i32 = (1 << 8) - (1 << 4);
    const TAG_MASK: i32 = (1 << 4) - (1 << 0);

    pub fn get_tag(&self) -> StellaTag {
        StellaTag(self.header & Self::TAG_MASK)
    }

    pub fn get_fields_count(&self) -> i32 {
        (self.header & Self::FIELD_COUNT_MASK) >> 4
    }

    pub fn set_header(&self, header: i32) {
        let header_ptr = self.as_ptr() as *mut i32;
        unsafe { *header_ptr = header };
    }

    pub fn get_field(&self, i: usize) -> StellaVarOrField {
        StellaVarOrField(unsafe { std::ptr::addr_of!(self.fields).add(i) } as *mut StellaReference)
    }

    pub fn as_ptr(&self) -> *mut StellaObject {
        unsafe { std::mem::transmute::<&StellaObject, *mut StellaObject>(self) }
    }

    pub fn get_layout(fields_count: usize) -> Layout {
        let header = Layout::new::<i32>();
        let fields = Layout::array::<*mut StellaObject>(fields_count).unwrap();
        header.extend(fields).unwrap().0
    }

    pub fn from_ptr(ptr: *mut u8) -> *mut StellaObject {
        ptr as *mut StellaObject
    }

    pub fn init_fields(&mut self, field_count: usize) {
        self.header &= !Self::FIELD_COUNT_MASK;
        self.header |= ((field_count as i32) << 4) & Self::FIELD_COUNT_MASK;
    }

    pub unsafe fn set_field(&mut self, index: usize, value: *mut StellaObject) {
        let fields_ptr = std::ptr::addr_of!(self.fields) as *mut *mut StellaObject;
        *fields_ptr.add(index) = value;
    }
}
