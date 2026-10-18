use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::catalog::model::{DetectionMethod, Tool, ToolStatus};

/// Check if a binary command exists in PATH and return its absolute path
pub fn command_path(cmd: &str) -> Option<PathBuf> {
    if let Ok(path_var) = env::var("PATH") {
        for dir in env::split_paths(&path_var) {
            let candidate = dir.join(cmd);
            if candidate.is_file() && is_executable(&candidate) {
                return Some(candidate);
            }
        }
    }
    // Check standard user directories if PATH in subshell is minimal
    if let Ok(home) = env::var("HOME") {
        let home_p = Path::new(&home);
        for extra in &[".cargo/bin", ".local/bin", "bin", ".asdf/shims"] {
            let candidate = home_p.join(extra).join(cmd);
            if candidate.is_file() && is_executable(&candidate) {
                return Some(candidate);
            }
        }
    }
    None
}

#[cfg(unix)]
fn is_executable(path: &Path) -> bool {
    use std::os::unix::fs::PermissionsExt;
    if let Ok(meta) = path.metadata() {
        return meta.permissions().mode() & 0o111 != 0;
    }
    false
}

#[cfg(not(unix))]
fn is_executable(path: &Path) -> bool {
    path.is_file()
}

/// Check if a deb package is installed via dpkg
pub fn is_dpkg_installed(pkg: &str) -> bool {
    Command::new("dpkg")
        .args(["-s", pkg])
        .output()
        .map(|out| out.status.success())
        .unwrap_or(false)
}

/// Check if a path relative to $HOME exists
pub fn home_path_exists(rel: &str) -> bool {
    if let Ok(home) = env::var("HOME") {
        Path::new(&home).join(rel).exists()
    } else {
        false
    }
}

/// Query version string from a binary with its version flag
pub fn query_version(cmd: &str, flag: &str) -> Option<String> {
    let output = Command::new(cmd).arg(flag).output().ok()?;
    if output.status.success() {
        let text = String::from_utf8_lossy(&output.stdout);
        let first_line = text.lines().next().unwrap_or("").trim();
        if !first_line.is_empty() {
            return Some(first_line.to_string());
        }
    }
    // Fallback to stderr if stdout was empty (some tools output version to stderr)
    let err_text = String::from_utf8_lossy(&output.stderr);
    let first_line = err_text.lines().next().unwrap_or("").trim();
    if !first_line.is_empty() {
        return Some(first_line.to_string());
    }
    None
}

/// Determine the ToolStatus for a given Tool definition
pub fn check_tool_status(tool: &Tool) -> ToolStatus {
    match tool.detection {
        DetectionMethod::Command(cmd) => {
            if let Some(path) = command_path(cmd) {
                let version = tool
                    .version_flag
                    .and_then(|flag| query_version(cmd, flag));
                ToolStatus::Installed {
                    version,
                    path: Some(path.to_string_lossy().to_string()),
                }
            } else {
                ToolStatus::NotInstalled
            }
        }
        DetectionMethod::Dpkg(pkg) => {
            if is_dpkg_installed(pkg) {
                ToolStatus::Installed {
                    version: None,
                    path: Some(format!("dpkg: {}", pkg)),
                }
            } else {
                ToolStatus::NotInstalled
            }
        }
        DetectionMethod::Path(rel) => {
            if home_path_exists(rel) {
                ToolStatus::Installed {
                    version: None,
                    path: Some(format!("~/{rel}")),
                }
            } else {
                ToolStatus::NotInstalled
            }
        }
    }
}
