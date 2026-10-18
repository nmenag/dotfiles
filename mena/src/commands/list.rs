use anyhow::Result;
use colored::Colorize;
use serde::Serialize;

use crate::catalog::model::{Category, ToolStatus};
use crate::catalog::registry::all_tools;
use crate::system::package::check_tool_status;

#[derive(Serialize)]
struct ToolJsonRecord {
    id: String,
    name: String,
    category: String,
    installed: bool,
    version: Option<String>,
    path: Option<String>,
    description: String,
}

pub fn handle_list(category_filter: Option<String>, json_output: bool) -> Result<()> {
    let filter = category_filter.as_deref().and_then(Category::from_str_loose);
    let mut tools = all_tools();

    if let Some(cat) = filter {
        tools.retain(|t| t.category == cat);
    }

    if json_output {
        let records: Vec<ToolJsonRecord> = tools
            .into_iter()
            .map(|t| {
                let status = check_tool_status(&t);
                let (installed, version, path) = match status {
                    ToolStatus::Installed { version, path } => (true, version, path),
                    ToolStatus::NotInstalled => (false, None, None),
                };
                ToolJsonRecord {
                    id: t.id.to_string(),
                    name: t.name.to_string(),
                    category: t.category.as_str().to_string(),
                    installed,
                    version,
                    path,
                    description: t.description.to_string(),
                }
            })
            .collect();

        println!("{}", serde_json::to_string_pretty(&records)?);
        return Ok(());
    }

    println!("\n{}", "=== mena Tool Catalog ===".bold().cyan());
    println!("Total tools cataloged: {}\n", tools.len().to_string().bold());

    let categories = Category::all();
    for cat in categories {
        let cat_tools: Vec<_> = tools.iter().filter(|t| t.category == *cat).collect();
        if cat_tools.is_empty() {
            continue;
        }

        println!("{} - {}", cat.display_name().bold().underline(), cat.description().dimmed());

        for tool in cat_tools {
            let status = check_tool_status(tool);
            let status_badge = match status {
                ToolStatus::Installed { version: Some(ref v), .. } => {
                    format!("[✓ {}]", v).green()
                }
                ToolStatus::Installed { .. } => "[✓ Installed]".green(),
                ToolStatus::NotInstalled => "[○ Missing]".yellow(),
            };

            println!(
                "  {:<16} {:<24} {:<20} {}",
                tool.id.cyan().bold(),
                tool.name,
                status_badge,
                tool.description.dimmed()
            );
        }
        println!();
    }

    println!("Tip: Run '{}' to launch the interactive installation wizard.", "mena install".cyan().bold());
    Ok(())
}
