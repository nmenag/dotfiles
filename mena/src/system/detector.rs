use std::collections::HashMap;
use std::env;
use std::fs;
use std::path::Path;

use super::package::command_path;

#[derive(Debug, Clone)]
pub struct SystemInfo {
    pub os_name: String,
    pub distro_id: String,
    pub version_id: String,
    pub codename: String,
    pub arch: String,
    pub current_user: String,
    pub shell: String,
    pub has_apt: bool,
    pub has_snap: bool,
    pub has_cargo: bool,
    pub has_asdf: bool,
    pub has_mise: bool,
    pub has_npm: bool,
    pub has_npx: bool,
    pub has_pnpm: bool,
}

impl SystemInfo {
    pub fn detect() -> Self {
        let os_release_map = read_os_release();

        let distro_id = os_release_map
            .get("ID")
            .cloned()
            .unwrap_or_else(|| "linux".to_string());

        let os_name = os_release_map
            .get("PRETTY_NAME")
            .or_else(|| os_release_map.get("NAME"))
            .cloned()
            .unwrap_or_else(|| "Linux System".to_string());

        let version_id = os_release_map
            .get("VERSION_ID")
            .cloned()
            .unwrap_or_else(|| "unknown".to_string());

        // Dynamic codename resolution (UBUNTU_CODENAME fallback)
        let codename = os_release_map
            .get("UBUNTU_CODENAME")
            .or_else(|| os_release_map.get("VERSION_CODENAME"))
            .cloned()
            .unwrap_or_else(|| "unknown".to_string());

        let arch = env::consts::ARCH.to_string();
        let current_user = env::var("USER").unwrap_or_else(|_| "unknown".to_string());
        let shell = env::var("SHELL").unwrap_or_else(|_| "/bin/bash".to_string());

        Self {
            os_name,
            distro_id,
            version_id,
            codename,
            arch,
            current_user,
            shell,
            has_apt: command_path("apt-get").is_some(),
            has_snap: command_path("snap").is_some(),
            has_cargo: command_path("cargo").is_some(),
            has_asdf: command_path("asdf").is_some() || Path::new(&env::var("HOME").unwrap_or_default()).join(".asdf/asdf.sh").exists(),
            has_mise: command_path("mise").is_some() || Path::new(&env::var("HOME").unwrap_or_default()).join(".local/bin/mise").exists(),
            has_npm: command_path("npm").is_some(),
            has_npx: command_path("npx").is_some(),
            has_pnpm: command_path("pnpm").is_some()
                || Path::new(&env::var("HOME").unwrap_or_default())
                    .join(".local/share/pnpm/pnpm")
                    .exists()
                || Path::new(&env::var("HOME").unwrap_or_default())
                    .join(".local/share/pnpm/bin/pnpm")
                    .exists(),
        }
    }
}

fn read_os_release() -> HashMap<String, String> {
    let mut map = HashMap::new();
    let paths = ["/etc/os-release", "/usr/lib/os-release"];

    for p in paths {
        if let Ok(content) = fs::read_to_string(p) {
            for line in content.lines() {
                let line = line.trim();
                if line.is_empty() || line.starts_with('#') {
                    continue;
                }
                if let Some((k, v)) = line.split_once('=') {
                    let clean_val = v.trim().trim_matches('"').trim_matches('\'');
                    map.insert(k.trim().to_string(), clean_val.to_string());
                }
            }
            break;
        }
    }
    map
}
