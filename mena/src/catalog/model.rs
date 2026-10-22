use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Category {
    Browsers,
    CliTools,
    Programs,
    ApiClients,
    VersionManagers,
    DevUtilities,
    Databases,
    AiAssistants,
    SkillManagement,
}

impl Category {
    pub fn all() -> &'static [Category] {
        &[
            Category::Browsers,
            Category::CliTools,
            Category::Programs,
            Category::ApiClients,
            Category::VersionManagers,
            Category::DevUtilities,
            Category::Databases,
            Category::AiAssistants,
            Category::SkillManagement,
        ]
    }

    /// Categories presented as interactive choices in the workstation wizard.
    /// CLI & Core System Tools are excluded because they are mandatory core tools
    /// that are installed automatically during workstation bootstrap.
    pub fn wizard_categories() -> &'static [Category] {
        &[
            Category::Browsers,
            Category::Programs,
            Category::ApiClients,
            Category::VersionManagers,
            Category::DevUtilities,
            Category::Databases,
            Category::AiAssistants,
            Category::SkillManagement,
        ]
    }

    pub fn is_core(&self) -> bool {
        matches!(self, Category::CliTools)
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Category::Browsers => "browsers",
            Category::CliTools => "cli",
            Category::Programs => "programs",
            Category::ApiClients => "api",
            Category::VersionManagers => "version-managers",
            Category::DevUtilities => "dev-utilities",
            Category::Databases => "databases",
            Category::AiAssistants => "ai-assistants",
            Category::SkillManagement => "skills",
        }
    }

    pub fn display_name(&self) -> &'static str {
        match self {
            Category::Browsers => "Web Browsers",
            Category::CliTools => "CLI, Shell & Core System Tools (Core)",
            Category::Programs => "Desktop Programs & Utilities",
            Category::ApiClients => "API Development Clients",
            Category::VersionManagers => "Version Managers",
            Category::DevUtilities => "Developer Utilities, IDEs & Terminals",
            Category::Databases => "Database Clients & Tools",
            Category::AiAssistants => "AI Coding Assistants & Adapters",
            Category::SkillManagement => "Agent Skills Management",
        }
    }

    pub fn description(&self) -> &'static str {
        match self {
            Category::Browsers => "Web browsers (Brave, Chrome) for daily and development use",
            Category::CliTools => "Core development tools (Git, Docker CE, Shell Dotfiles, Build Essentials, cURL, Wget) installed automatically",
            Category::Programs => "Desktop programs & system utilities (BleachBit, Flameshot, VLC, Stacer)",
            Category::ApiClients => "API development, exploration, and testing clients (Bruno, Postman)",
            Category::VersionManagers => "ASDF & Mise runtime version managers and polyglot toolchains (Node, Python, Ruby, etc.)",
            Category::DevUtilities => "Code editors, terminal emulators and workspace managers",
            Category::Databases => "Database GUI clients (pgAdmin, MongoDB Compass, DBeaver, DbGate)",
            Category::AiAssistants => "Terminal AI assistants (Claude, OpenCode, Codex, Kilo, Agy, Pi) with unified instructions",
            Category::SkillManagement => "Official 'skills' CLI for discovering and managing Agent Skills",
        }
    }

    pub fn from_str_loose(input: &str) -> Option<Category> {
        let normalized = input.to_lowercase().replace('_', "-");
        match normalized.as_str() {
            "browser" | "browsers" | "web" => Some(Category::Browsers),
            "cli" | "clitools" | "core" | "system" | "shell" | "zsh" | "bash" | "dotfiles" => Some(Category::CliTools),
            "program" | "programs" | "app" | "apps" | "desktop" => Some(Category::Programs),
            "api" | "apis" | "apiclient" | "apiclients" | "api-client" | "api-clients" | "postman" | "bruno" => Some(Category::ApiClients),
            "version-manager" | "version-managers" | "vm" | "runtime" | "runtimes" | "asdf" | "mise" | "languages" => Some(Category::VersionManagers),
            "dev" | "dev-utilities" | "utils" | "utilities" | "ide" | "ides" => Some(Category::DevUtilities),
            "db" | "database" | "databases" => Some(Category::Databases),
            "ai" | "ai-assistants" | "assistants" | "agents" => Some(Category::AiAssistants),
            "skill" | "skills" => Some(Category::SkillManagement),
            _ => None,
        }
    }
}

impl fmt::Display for Category {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.display_name())
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum InstallMethod {
    Script(&'static str),
    AiAdapter(&'static str),
    AptPackage(&'static str),
    SnapPackage { name: &'static str, classic: bool },
    ShellCommand(&'static str),
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DetectionMethod {
    Command(&'static str),
    Dpkg(&'static str),
    Path(&'static str),
    CommandOrFlatpak {
        cmd: &'static str,
        flatpak_id: &'static str,
    },
    CommandOrDpkg {
        cmd: &'static str,
        pkg: &'static str,
    },
}

#[derive(Debug, Clone)]
pub struct Tool {
    pub id: &'static str,
    pub name: &'static str,
    pub category: Category,
    pub description: &'static str,
    pub dependencies: &'static [&'static str],
    pub install_method: InstallMethod,
    pub detection: DetectionMethod,
    pub version_flag: Option<&'static str>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ToolStatus {
    Installed {
        version: Option<String>,
        path: Option<String>,
    },
    NotInstalled,
}

impl ToolStatus {
    pub fn is_installed(&self) -> bool {
        matches!(self, ToolStatus::Installed { .. })
    }

    pub fn version(&self) -> Option<&str> {
        match self {
            ToolStatus::Installed { version: Some(v), .. } => Some(v.as_str()),
            _ => None,
        }
    }
}
