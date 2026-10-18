use std::process::Command;
use anyhow::{Context, Result};
use colored::Colorize;

use crate::executor::runner::find_dotfiles_root;

pub fn handle_core(dry_run: bool) -> Result<()> {
    println!("\n{}", "=== mena Core Workstation Foundations Setup ===".bold().cyan());
    println!("Installing or repairing core workstation essentials (Git, Docker, Build Tools, Snapd)...");

    let root = find_dotfiles_root();
    let script_path = root.join("scripts/core.sh");

    if !script_path.exists() {
        anyhow::bail!("Core installation script not found at: {}", script_path.display());
    }

    let mut cmd = Command::new("bash");
    cmd.arg(&script_path);

    if dry_run {
        println!("{}", "[DRY-RUN] Executing core script in dry-run mode...".yellow().bold());
        cmd.arg("--dry-run");
    }

    let status = cmd
        .status()
        .with_context(|| format!("Failed to execute {}", script_path.display()))?;

    if !status.success() {
        anyhow::bail!("Core installation completed with errors (exit code: {}). Review the failed components in the summary above.", status);
    }

    println!("\n{}", "✓ Core workstation foundations are up to date and verified!".green().bold());
    Ok(())
}
