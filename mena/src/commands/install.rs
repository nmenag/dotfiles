use anyhow::Result;
use colored::Colorize;

use crate::catalog::model::Category;
use crate::catalog::registry::{all_tools, find_tool, tools_by_category};
use crate::executor::runner::execute_plan;
use crate::interactive::wizard::run_wizard;
use crate::planner::plan::InstallPlan;
use crate::system::detector::SystemInfo;
use crate::system::package::check_tool_status;

pub fn handle_install(
    category_arg: Option<String>,
    dry_run: bool,
    non_interactive_yes: bool,
    system: &SystemInfo,
) -> Result<()> {
    if category_arg
        .as_deref()
        .map(|s| s.eq_ignore_ascii_case("core"))
        .unwrap_or(false)
    {
        return super::core::handle_core(dry_run);
    }

    // A specific tool id (e.g. `mena install obsidian`) installs just that tool.
    if let Some(tool) = category_arg.as_deref().and_then(|a| find_tool(&a.to_lowercase())) {
        if check_tool_status(&tool).is_installed() && tool.id != "ai-sync" && tool.id != "shell-dotfiles" {
            println!("{} is already installed.", tool.name.green().bold());
            return Ok(());
        }
        let plan = InstallPlan::build(&[tool.id.to_string()], system);
        println!("{}", plan.render_summary());
        let report = execute_plan(&plan, dry_run)?;
        report.print_summary();
        return Ok(());
    }

    if let Some(arg) = category_arg.as_deref() {
        if Category::from_str_loose(arg).is_none() {
            anyhow::bail!("'{}' is not a known tool or category. Run `mena list` to see available ones.", arg);
        }
    }

    let filter_category = category_arg.as_deref().and_then(Category::from_str_loose);

    if non_interactive_yes {
        println!("\n{}", "Running non-interactive installation (--yes)...".bold().cyan());

        let candidate_tools = match filter_category {
            Some(cat) => tools_by_category(cat),
            None => all_tools(),
        };

        // Select uninstalled tools or adapters needing sync
        let selected_ids: Vec<String> = candidate_tools
            .iter()
            .filter(|t| !check_tool_status(t).is_installed() || t.id == "ai-sync" || t.id == "shell-dotfiles")
            .map(|t| t.id.to_string())
            .collect();

        if selected_ids.is_empty() {
            println!("{}", "All candidate tools are already installed and up to date.".green().bold());
            return Ok(());
        }

        let plan = InstallPlan::build(&selected_ids, system);
        println!("{}", plan.render_summary());

        let report = execute_plan(&plan, dry_run)?;
        report.print_summary();
        return Ok(());
    }

    // Interactive Wizard Mode
    match run_wizard(filter_category, system)? {
        Some(plan) => {
            let report = execute_plan(&plan, dry_run)?;
            report.print_summary();
        }
        None => {
            // Guarantee: zero installations or modifications executed
            println!("{}", "Cancelled: No actions were performed.".bold().dimmed());
        }
    }

    Ok(())
}
