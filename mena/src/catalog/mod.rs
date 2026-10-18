pub mod model;
pub mod registry;

pub use model::{Category, DetectionMethod, InstallMethod, Tool, ToolStatus};
pub use registry::{all_tools, find_tool, tools_by_category};
