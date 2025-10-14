use std::alloc::Layout;
#[repr(C)]
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

    pub fn get_field_count(&self) -> i32 {
        (self.header & Self::FIELD_COUNT_MASK) >> 4
    }

    pub fn get_layout(fields_count: usize) -> Layout {
        let header = Layout::new::<i32>();
        let fields = Layout::array::<*mut StellaObject>(fields_count).unwrap();
        header.extend(fields).unwrap().0
    }
}

pub type RootReference = *mut *mut StellaObject;
