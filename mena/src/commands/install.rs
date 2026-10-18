use anyhow::Result;
use colored::Colorize;

use crate::catalog::model::Category;
use crate::catalog::registry::{all_tools, tools_by_category};
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
