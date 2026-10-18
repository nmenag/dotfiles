use std::collections::{HashSet, VecDeque};
use colored::Colorize;

use crate::catalog::model::{InstallMethod, Tool, ToolStatus};
use crate::catalog::registry::find_tool;
use crate::system::detector::SystemInfo;
use crate::system::package::check_tool_status;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ActionType {
    InstallFresh,
    VerifyOrSync,
    InstallDependency,
}

#[derive(Debug, Clone)]
pub struct PlannedAction {
    pub tool_id: String,
    pub tool_name: String,
    pub action_type: ActionType,
    pub install_method: InstallMethod,
    pub summary: String,
}

#[derive(Debug, Clone)]
pub struct ToolPlanItem {
    pub tool: Tool,
    pub initial_status: ToolStatus,
    pub is_dependency: bool,
}

#[derive(Debug, Clone)]
pub struct InstallPlan {
    pub selected_tools: Vec<ToolPlanItem>,
    pub actions: Vec<PlannedAction>,
    pub dependencies: Vec<String>,
    pub warnings: Vec<String>,
    pub requires_sudo: bool,
}

impl InstallPlan {
    pub fn build(selected_ids: &[String], system: &SystemInfo) -> Self {
        let mut plan_items = Vec::new();
        let mut actions = Vec::new();
        let mut dependencies = Vec::new();
        let mut warnings = Vec::new();
        let mut requires_sudo = false;

        let mut processed_ids: HashSet<String> = HashSet::new();
        let mut queue: VecDeque<(String, bool)> = VecDeque::new();

        for id in selected_ids {
            queue.push_back((id.clone(), false));
        }

        while let Some((id, is_dep)) = queue.pop_front() {
            if processed_ids.contains(&id) {
                continue;
            }
            processed_ids.insert(id.clone());

            let tool = match find_tool(&id) {
                Some(t) => t,
                None => {
                    warnings.push(format!("Tool '{}' is not recognized in the catalog.", id));
                    continue;
                }
            };

            let status = check_tool_status(&tool);

            // Dependency checks
            for dep_id in tool.dependencies {
                if !processed_ids.contains(*dep_id) {
                    if let Some(dep_tool) = find_tool(dep_id) {
                        let dep_status = check_tool_status(&dep_tool);
                        if !dep_status.is_installed() {
                            dependencies.push(dep_id.to_string());
                            queue.push_back((dep_id.to_string(), true));
                        }
                    }
                }
            }

            // Check system requirements
            match &tool.install_method {
                InstallMethod::AptPackage(_) => {
                    requires_sudo = true;
                    if !system.has_apt {
                        warnings.push(format!(
                            "Tool '{}' requires APT, but apt-get was not detected.",
                            tool.name
                        ));
                    }
                }
                InstallMethod::SnapPackage { .. } => {
                    requires_sudo = true;
                    if !system.has_snap {
                        warnings.push(format!(
                            "Tool '{}' requires Snap, but snapd was not detected.",
                            tool.name
                        ));
                    }
                }
                InstallMethod::Script(script_path) => {
                    // Scripts that invoke apt/sudo
                    if script_path.contains("brave")
                        || script_path.contains("docker")
                        || script_path.contains("programs")
                        || script_path.contains("ghostty")
                        || script_path.contains("android-studio")
                        || script_path.contains("pgadmin")
                        || script_path.contains("mongocompass")
                        || script_path.contains("orca")
                        || script_path.contains("mise")
                        || script_path.contains("cursor")
                        || script_path.contains("postman")
                        || script_path.contains("bruno")
                    {
                        requires_sudo = true;
                    }
                }
                _ => {}
            }

            let action_type = if is_dep {
                ActionType::InstallDependency
            } else if status.is_installed() {
                ActionType::VerifyOrSync
            } else {
                ActionType::InstallFresh
            };

            let action_summary = match (&action_type, &tool.install_method) {
                (ActionType::VerifyOrSync, InstallMethod::AiAdapter(p)) => {
                    format!("Sync and verify instructions/skills adapter via {}", p)
                }
                (ActionType::VerifyOrSync, _) => {
                    format!("Already installed. Run idempotency check / upgrade via {:?}", tool.install_method)
                }
                (ActionType::InstallFresh, InstallMethod::Script(s)) => {
                    format!("Execute official workstation script '{}'", s)
                }
                (ActionType::InstallFresh, InstallMethod::AiAdapter(a)) => {
                    format!("Provision adapter and symlink guidelines via '{}'", a)
                }
                (ActionType::InstallFresh, InstallMethod::AptPackage(pkg)) => {
                    format!("Install system APT package '{}'", pkg)
                }
                (ActionType::InstallFresh, InstallMethod::SnapPackage { name, classic }) => {
                    format!("Install Snap package '{}' (classic: {})", name, classic)
                }
                (ActionType::InstallFresh, InstallMethod::ShellCommand(c)) => {
                    format!("Execute shell command '{}'", c)
                }
                (ActionType::InstallDependency, _) => {
                    format!("Install prerequisite dependency for other tools")
                }
            };

            actions.push(PlannedAction {
                tool_id: tool.id.to_string(),
                tool_name: tool.name.to_string(),
                action_type,
                install_method: tool.install_method.clone(),
                summary: action_summary,
            });

            plan_items.push(ToolPlanItem {
                tool,
                initial_status: status,
                is_dependency: is_dep,
            });
        }

        Self {
            selected_tools: plan_items,
            actions,
            dependencies,
            warnings,
            requires_sudo,
        }
    }

    pub fn is_empty(&self) -> bool {
        self.selected_tools.is_empty()
    }

    /// Render a rich, human-readable summary of the plan
    pub fn render_summary(&self) -> String {
        let mut out = String::new();

        out.push_str(&format!("\n{}\n", "================== PRE-INSTALLATION SUMMARY ==================".bold().cyan()));

        let to_install: Vec<&ToolPlanItem> = self
            .selected_tools
            .iter()
            .filter(|i| !i.is_dependency && !i.initial_status.is_installed())
            .collect();

        let already_installed: Vec<&ToolPlanItem> = self
            .selected_tools
            .iter()
            .filter(|i| !i.is_dependency && i.initial_status.is_installed())
            .collect();

        let deps_to_install: Vec<&ToolPlanItem> = self
            .selected_tools
            .iter()
            .filter(|i| i.is_dependency)
            .collect();

        // 1. New tools
        out.push_str(&format!("\n{}: ({})\n", "1. Tools to be Installed".bold().green(), to_install.len()));
        if to_install.is_empty() {
            out.push_str("   (None - all selected tools are already installed)\n");
        } else {
            for item in &to_install {
                out.push_str(&format!("   {} {} ({})\n", "+".green().bold(), item.tool.name.bold(), item.tool.category.as_str().dimmed()));
            }
        }

        // 2. Already installed
        out.push_str(&format!("\n{}: ({})\n", "2. Already Installed (Will verify/re-sync)".bold().blue(), already_installed.len()));
        if already_installed.is_empty() {
            out.push_str("   (None)\n");
        } else {
            for item in &already_installed {
                let ver = item.initial_status.version().unwrap_or("detected");
                out.push_str(&format!("   {} {} [{}]\n", "✓".blue().bold(), item.tool.name, ver.dimmed()));
            }
        }

        // 3. Dependencies
        if !deps_to_install.is_empty() {
            out.push_str(&format!("\n{}: ({})\n", "3. Prerequisite Dependencies Needed".bold().yellow(), deps_to_install.len()));
            for item in &deps_to_install {
                out.push_str(&format!("   {} {} (required by selected tools)\n", "→".yellow().bold(), item.tool.name));
            }
        }

        // 4. Actions breakdown
        out.push_str(&format!("\n{}: ({})\n", "4. Planned Actions".bold(), self.actions.len()));
        for (idx, action) in self.actions.iter().enumerate() {
            let badge = match action.action_type {
                ActionType::InstallFresh => "[INSTALL]".green(),
                ActionType::VerifyOrSync => "[VERIFY]".blue(),
                ActionType::InstallDependency => "[DEP]".yellow(),
            };
            out.push_str(&format!("   {}. {:10} {:<24} -> {}\n", idx + 1, badge, action.tool_name, action.summary.dimmed()));
        }

        // 5. Warnings and permissions
        if !self.warnings.is_empty() || self.requires_sudo {
            out.push_str(&format!("\n{}:\n", "5. Warnings & Prerequisites".bold().red()));
            if self.requires_sudo {
                out.push_str(&format!("   {} Some actions will require administrative (`sudo`) privileges for APT or system packages.\n", "!".yellow().bold()));
            }
            for w in &self.warnings {
                out.push_str(&format!("   {} {}\n", "!".red().bold(), w));
            }
        }

        out.push_str(&format!("\n{}\n", "==============================================================".cyan()));
        out
    }
}
