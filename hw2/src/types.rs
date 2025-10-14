use std::alloc::Layout;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct StellaObject {
    pub header: i32,
    pub fields: *mut *mut StellaObject,
}

impl StellaObject {
    const FIELD_COUNT_MASK: i32 = (1 << 8) - (1 << 4);
    const TAG_MASK: i32 = (1 << 4) - (1 << 0);

    pub fn get_tag(&self) -> i32 {
        self.header & Self::TAG_MASK
    }

    pub fn get_fields_count(&self) -> i32 {
        (self.header & Self::FIELD_COUNT_MASK) >> 4
    }

    pub fn get_field(&self, i: usize) -> *mut *mut StellaObject {
        unsafe { (&self.fields).add(i) }
    }

    pub fn get_tag_ptr(this: *mut StellaObject) -> i32 {
        Self::get_self(this).get_tag()
    }

    pub fn get_fields_count_ptr(this: *mut StellaObject) -> i32 {
        Self::get_self(this).get_fields_count()
    }

    pub fn get_field_ptr(this: *mut StellaObject, i: usize) -> *mut *mut StellaObject {
        Self::get_self(this).get_field(i)
    }

    fn get_self(this: *mut StellaObject) -> StellaObject {
        unsafe { *this }
    }

    pub fn get_layout(fields_count: usize) -> Layout {
        let header = Layout::new::<i32>();
        let fields = Layout::array::<*mut StellaObject>(fields_count).unwrap();
        header.extend(fields).unwrap().0
    }

    pub fn from_ptr(ptr: *mut u8) -> *mut StellaObject {
        ptr as *mut StellaObject
    }
}

pub type RootReference = *mut *mut StellaObject;
