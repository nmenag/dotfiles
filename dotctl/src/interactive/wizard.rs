use anyhow::{Context, Result};
use colored::Colorize;
use dialoguer::{Confirm, Input, MultiSelect, Select, theme::ColorfulTheme};

use crate::catalog::model::Category;
use crate::catalog::registry::tools_by_category;
use crate::planner::plan::InstallPlan;
use crate::system::detector::SystemInfo;
use crate::system::package::check_tool_status;

pub struct WizardPreferences {
    pub default_browser: Option<String>,
    pub git_name: Option<String>,
    pub git_email: Option<String>,
    pub vscode_extensions: bool,
}

pub fn run_wizard(
    filter_category: Option<Category>,
    system: &SystemInfo,
) -> Result<Option<InstallPlan>> {
    let theme = ColorfulTheme::default();

    println!("\n{}", "=== dotctl Interactive Workstation Setup ===".bold().cyan());
    println!("Operating System: {} ({}) | User: {}", system.os_name.bold(), system.codename, system.current_user);
    if let Some(cat) = filter_category {
        println!("Category Filter: {}", cat.display_name().bold().yellow());
    }
    println!("Use [Space] to select/deselect tools, [Enter] to confirm category.\n");

    let categories_to_query: Vec<Category> = if let Some(cat) = filter_category {
        vec![cat]
    } else {
        Category::all().to_vec()
    };

    let mut current_selected_ids: Vec<String> = Vec::new();

    // Main interaction loop allowing modification before final confirmation
    loop {
        current_selected_ids.clear();

        for cat in &categories_to_query {
            let tools = tools_by_category(*cat);
            if tools.is_empty() {
                continue;
            }

            println!("\n{} - {}", cat.display_name().bold().underline(), cat.description().dimmed());

            let mut items: Vec<String> = Vec::new();
            let mut defaults: Vec<bool> = Vec::new();

            for tool in &tools {
                let status = check_tool_status(tool);
                let status_str = if let Some(ver) = status.version() {
                    format!("Installed: {}", ver).green()
                } else if status.is_installed() {
                    "Installed".green()
                } else {
                    "Not Installed".yellow()
                };

                let item_text = format!("{:<24} [{}] - {}", tool.name.bold(), status_str, tool.description);
                items.push(item_text);

                // Default selection: pre-select if uninstalled or if it's core/shell/ai
                let preselect = !status.is_installed() || tool.id == "shell-dotfiles" || tool.id == "ai-sync";
                defaults.push(preselect);
            }

            let selections = MultiSelect::with_theme(&theme)
                .with_prompt(format!("Select tools in {}", cat.display_name()))
                .items(&items)
                .defaults(&defaults)
                .interact()
                .context("Failed reading multi-select input")?;

            for idx in selections {
                current_selected_ids.push(tools[idx].id.to_string());
            }
        }

        if current_selected_ids.is_empty() {
            println!("\n{}", "No tools were selected.".yellow());
            let retry = Confirm::with_theme(&theme)
                .with_prompt("Would you like to select tools again?")
                .default(true)
                .interact()?;
            if retry {
                continue;
            } else {
                println!("{}", "Setup aborted by user. No changes were made.".bold());
                return Ok(None);
            }
        }

        // --- Step 2: Query preferences for relevant selections ---
        ask_preferences(&current_selected_ids, &theme)?;

        // --- Step 3: Calculate plan and present summary ---
        let plan = InstallPlan::build(&current_selected_ids, system);
        println!("{}", plan.render_summary());

        // --- Step 4: Review Menu (Proceed, Modify, Cancel) ---
        let review_options = [
            "Proceed with installation (Execute approved actions)",
            "Modify selections (Return to tool categories)",
            "Cancel (Abort setup without making any changes)",
        ];

        let choice = Select::with_theme(&theme)
            .with_prompt("What would you like to do?")
            .items(&review_options)
            .default(0)
            .interact()
            .context("Failed reading review choice")?;

        match choice {
            0 => {
                // Final explicit confirmation
                let confirmed = Confirm::with_theme(&theme)
                    .with_prompt("Are you sure you want to begin installation now?")
                    .default(true)
                    .interact()?;

                if confirmed {
                    return Ok(Some(plan));
                } else {
                    println!("{}", "\nOperation canceled at confirmation step. No changes made.".yellow().bold());
                    return Ok(None);
                }
            }
            1 => {
                println!("\n{}", "Returning to tool selection...".cyan());
                continue;
            }
            _ => {
                println!("{}", "\nSetup canceled by user. No installations or modifications were executed.".bold());
                return Ok(None);
            }
        }
    }
}

fn ask_preferences(selected_ids: &[String], theme: &ColorfulTheme) -> Result<WizardPreferences> {
    let mut default_browser = None;
    let mut git_name = None;
    let mut git_email = None;
    let mut vscode_extensions = true;

    // Check multiple browsers
    let selected_browsers: Vec<&str> = selected_ids
        .iter()
        .filter(|id| *id == "brave" || *id == "chrome")
        .map(|s| s.as_str())
        .collect();

    if selected_browsers.len() > 1 {
        let browser_names: Vec<&str> = selected_browsers
            .iter()
            .map(|id| match *id {
                "brave" => "Brave Browser",
                "chrome" => "Google Chrome",
                _ => *id,
            })
            .collect();

        let choice = Select::with_theme(theme)
            .with_prompt("Multiple browsers selected. Which should be your preferred default?")
            .items(&browser_names)
            .default(0)
            .interact()?;
        default_browser = Some(selected_browsers[choice].to_string());
    }

    // Check git preferences if selected
    if selected_ids.contains(&"git".to_string()) {
        let git_user_configured = std::process::Command::new("git")
            .args(["config", "--global", "user.name"])
            .output()
            .map(|o| !o.stdout.is_empty())
            .unwrap_or(false);

        if !git_user_configured {
            let prompt_git = Confirm::with_theme(theme)
                .with_prompt("Git identity is not configured. Would you like to configure name and email now?")
                .default(true)
                .interact()?;

            if prompt_git {
                let name: String = Input::with_theme(theme)
                    .with_prompt("Enter your Git name")
                    .interact_text()?;
                let email: String = Input::with_theme(theme)
                    .with_prompt("Enter your Git email")
                    .interact_text()?;
                git_name = Some(name);
                git_email = Some(email);
            }
        }
    }

    // Check vscode preferences
    if selected_ids.contains(&"vscode".to_string()) {
        vscode_extensions = Confirm::with_theme(theme)
            .with_prompt("Install curated VS Code extensions (Rust, Elixir, Ruby, Docker, Tailwind)?")
            .default(true)
            .interact()?;
    }

    Ok(WizardPreferences {
        default_browser,
        git_name,
        git_email,
        vscode_extensions,
    })
}
