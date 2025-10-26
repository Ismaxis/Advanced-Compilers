use std::alloc::Layout;

use c_enum::c_enum;

#[repr(C)]
pub struct StellaObject {
    pub header: i32,
    pub fields: StellaReference,
}

pub type StellaReference = &'static mut StellaObject;

pub type StellaVarOrField = &'static mut StellaReference;

impl StellaObject {
    const FIELD_COUNT_MASK: i32 = (1 << 8) - (1 << 4);
    const TAG_MASK: i32 = (1 << 4) - (1 << 0);

    pub fn get_tag(&self) -> StellaTag {
        StellaTag(self.header & Self::TAG_MASK)
    }

    pub fn get_fields_count(&self) -> i32 {
        (self.header & Self::FIELD_COUNT_MASK) >> 4
    }

    pub fn set_header(&mut self, header: i32) {
        let header_ptr = std::ptr::addr_of_mut!(self.header);
        unsafe { *header_ptr = header };
    }

    pub fn get_field(&self, i: usize) -> StellaVarOrField {
        ptr_to_ref(unsafe { std::ptr::addr_of!(self.fields).add(i) })
    }

    pub fn as_ptr(&self) -> *mut Self {
        unsafe { std::mem::transmute::<&Self, *mut Self>(self) }
    }

    pub fn get_layout(fields_count: usize) -> Layout {
        let header = Layout::new::<i32>();
        let fields = Layout::array::<*mut Self>(fields_count).unwrap();
        header.extend(fields).unwrap().0
    }

    pub fn from_ptr(ptr: *mut u8) -> *mut Self {
        ptr as *mut Self
    }

    pub fn init_fields(&mut self, field_count: usize) {
        self.header &= !Self::FIELD_COUNT_MASK;
        self.header |= ((field_count as i32) << 4) & Self::FIELD_COUNT_MASK;
    }

    pub unsafe fn set_field(&mut self, index: usize, value: *mut Self) {
        let fields_ptr = std::ptr::addr_of!(self.fields) as *mut *mut Self;
        *fields_ptr.add(index) = value;
    }
}

fn ptr_to_ref(object: *const StellaReference) -> StellaVarOrField {
    unsafe { std::mem::transmute::<*const StellaReference, &'static mut StellaReference>(object) }
}

pub(crate) fn ptr_ptr_to_ref_ref(object: *mut *mut StellaObject) -> StellaVarOrField {
    unsafe { std::mem::transmute::<*mut *mut StellaObject, &'static mut StellaReference>(object) }
}

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

impl std::fmt::Display for StellaTag {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = match *self {
            StellaTag::TAG_ZERO => "ZERO",
            StellaTag::TAG_SUCC => "SUCC",
            StellaTag::TAG_FALSE => "FALSE",
            StellaTag::TAG_TRUE => "TRUE",
            StellaTag::TAG_FN => "FN",
            StellaTag::TAG_REF => "REF",
            StellaTag::TAG_UNIT => "UNIT",
            StellaTag::TAG_TUPLE => "TUPLE",
            StellaTag::TAG_INL => "INL",
            StellaTag::TAG_INR => "INR",
            StellaTag::TAG_EMPTY => "EMPTY",
            StellaTag::TAG_CONS => "CONS",
            _ => "UNKNOWN",
        };
        write!(f, "{s}")
    }
}
