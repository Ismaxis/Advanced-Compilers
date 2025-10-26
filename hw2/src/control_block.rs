use std::alloc::Layout;

type ControlBlockHeader = (); // Not needed ;(

#[repr(C)]
pub struct ControlBlock<T> {
    pub some_header: ControlBlockHeader,
    pub value: T,
}

pub(crate) fn ptr_to_ref<U>(value: *mut U) -> &'static mut U {
    unsafe { value.as_mut::<'static>() }.unwrap()
}

impl<T> ControlBlock<T> {
    pub fn as_ptr(&mut self) -> *mut Self {
        std::ptr::addr_of_mut!(*self)
    }

    pub fn from_ptr<U>(value: *mut U) -> &'static mut Self {
        ptr_to_ref(value as *mut ControlBlock<T>)
    }

    pub fn from_var_of_field(root: &&mut &mut T) -> &'static mut Self {
        Self::from_ptr(Self::from_value_ptr(**root))
    }

    fn from_value_ptr(value: *const T) -> *mut Self {
        let offset = std::mem::offset_of!(ControlBlock<T>, value);
        (value as *const u8).wrapping_sub(offset) as *mut Self
    }

    pub fn get_layout(value_layout: Layout) -> Layout {
        let header = Self::header_layout();

        let (full_layout, _value_offset) = header.extend(value_layout).unwrap();
        full_layout
    }

    pub fn header_layout() -> Layout {
        let header = Layout::new::<ControlBlockHeader>();
        header
    }

    pub fn get_value(&mut self) -> &'static mut T {
        ptr_to_ref(std::ptr::addr_of_mut!(self.value))
    }
}
