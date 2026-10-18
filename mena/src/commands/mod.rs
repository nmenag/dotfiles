pub mod core;
pub mod doctor;
pub mod install;
pub mod list;
pub mod update;

pub use core::handle_core;
pub use doctor::handle_doctor;
pub use install::handle_install;
pub use list::handle_list;
pub use update::handle_update;
