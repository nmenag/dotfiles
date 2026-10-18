use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Category {
    Browsers,
    CliTools,
    Runtimes,
    DevUtilities,
    AiAssistants,
    SkillManagement,
    ShellEnvironment,
}

impl Category {
    pub fn all() -> &'static [Category] {
        &[
            Category::Browsers,
            Category::CliTools,
            Category::Runtimes,
            Category::DevUtilities,
            Category::AiAssistants,
            Category::SkillManagement,
            Category::ShellEnvironment,
        ]
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Category::Browsers => "browsers",
            Category::CliTools => "cli",
            Category::Runtimes => "runtimes",
            Category::DevUtilities => "dev-utilities",
            Category::AiAssistants => "ai-assistants",
            Category::SkillManagement => "skills",
            Category::ShellEnvironment => "shell",
        }
    }

    pub fn display_name(&self) -> &'static str {
        match self {
            Category::Browsers => "Web Browsers",
            Category::CliTools => "CLI & Core System Tools",
            Category::Runtimes => "Language Runtimes & Version Managers",
            Category::DevUtilities => "Developer Utilities, IDEs & Terminals",
            Category::AiAssistants => "AI Coding Assistants & Adapters",
            Category::SkillManagement => "Agent Skills Management",
            Category::ShellEnvironment => "Shell Dotfiles, Oh My Zsh & Themes",
        }
    }

    pub fn description(&self) -> &'static str {
        match self {
            Category::Browsers => "Web browsers (Brave, Chrome) for daily and development use",
            Category::CliTools => "Core development tools (Git, Docker CE, Build Essentials, cURL, Wget)",
            Category::Runtimes => "ASDF & Mise runtime version managers and language plugins (Node, Python, Ruby, etc.)",
            Category::DevUtilities => "Code editors, terminal emulators, workspace managers and database tools",
            Category::AiAssistants => "Terminal AI assistants (Claude, OpenCode, Codex, Kilo, Agy, Pi) with unified instructions",
            Category::SkillManagement => "Official 'skills' CLI for discovering and managing Agent Skills",
            Category::ShellEnvironment => "Unified Bash and Zsh configurations, Oh My Zsh plugins and DevEx prompt theme",
        }
    }

    pub fn from_str_loose(input: &str) -> Option<Category> {
        let normalized = input.to_lowercase().replace('_', "-");
        match normalized.as_str() {
            "browser" | "browsers" | "web" => Some(Category::Browsers),
            "cli" | "clitools" | "core" | "system" => Some(Category::CliTools),
            "runtime" | "runtimes" | "asdf" | "languages" => Some(Category::Runtimes),
            "dev" | "dev-utilities" | "utils" | "utilities" | "ide" | "ides" => Some(Category::DevUtilities),
            "ai" | "ai-assistants" | "assistants" | "agents" => Some(Category::AiAssistants),
            "skill" | "skills" => Some(Category::SkillManagement),
            "shell" | "zsh" | "bash" | "dotfiles" => Some(Category::ShellEnvironment),
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
