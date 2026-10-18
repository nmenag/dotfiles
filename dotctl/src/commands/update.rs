use std::process::Command;

use anyhow::Result;
use colored::Colorize;

use crate::executor::runner::find_dotfiles_root;
use crate::system::package::home_path_exists;

pub fn handle_update() -> Result<()> {
    let root = find_dotfiles_root();

    println!("\n{}", "=== dotctl Update Manager ===".bold().cyan());

    // 1. Synchronize AI adapters
    println!("\n{}:", "1. Synchronizing AI Coding Agent Adapters".bold());
    let ai_script = root.join("scripts/ai-tools.sh");
    if ai_script.exists() {
        let status = Command::new("bash").arg(&ai_script).status()?;
        if status.success() {
            println!("   {} AI adapters synchronized successfully", "✓".green().bold());
        } else {
            println!("   {} AI adapters sync failed with code {:?}", "✗".red().bold(), status.code());
        }
    } else {
        println!("   {} AI sync script not found at {}", "○".yellow().bold(), ai_script.display());
    }

    // 2. Oh My Zsh update
    if home_path_exists(".oh-my-zsh") {
        println!("\n{}:", "2. Updating Oh My Zsh Framework".bold());
        let omz_status = Command::new("zsh")
            .args(["-c", "source ~/.zshrc 2>/dev/null; omz update || true"])
            .status();
        if let Ok(st) = omz_status {
            if st.success() {
                println!("   {} Oh My Zsh is up-to-date", "✓".green().bold());
            }
        }
    }

    // 3. Update system package index
    println!("\n{}:", "3. Refreshing System Package Lists (APT)".bold());
    let apt_status = Command::new("sudo").args(["apt-get", "update", "-y"]).status();
    match apt_status {
        Ok(st) if st.success() => {
            println!("   {} System package lists refreshed successfully", "✓".green().bold());
        }
        _ => {
            println!("   {} Failed to refresh APT package lists (sudo access required)", "✗".yellow().bold());
        }
    }

    println!("\n{}", "Update routines completed!".bold().green());
    Ok(())
}
