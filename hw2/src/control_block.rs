use std::alloc::Layout;

#[repr(C)]
pub struct ControlBlock<T: ?Sized> {
    pub some_header: u64, // TODO:
    pub value: T,
}

impl<T> ControlBlock<T> {
    #[allow(dead_code)]
    pub fn new(value: T) -> Self {
        Self {
            some_header: 0xDEADBEEF,
            value,
        }
    }

    pub fn from_value_ptr(value: *const T) -> *mut Self {
        let offset = std::mem::offset_of!(ControlBlock<T>, value);
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

    pub fn get_value(&mut self) -> *mut T {
        return std::ptr::addr_of_mut!(self.value);
    }
}

impl ControlBlock<()> {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_from_value_ptr() {
        let value = 42;
        let control_block = ControlBlock::new(value);
        let ptr = (&control_block.value) as *const i32;
        let rc_ptr = ControlBlock::from_value_ptr(ptr);
        unsafe {
            assert_eq!(*(*rc_ptr).get_value(), 42);
        }
    }
}
