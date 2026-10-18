pub mod detector;
pub mod package;

pub use detector::SystemInfo;
pub use package::{check_tool_status, command_path, home_path_exists, is_dpkg_installed, query_version};
