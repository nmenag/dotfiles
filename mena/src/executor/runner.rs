use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result};
use colored::Colorize;
use indicatif::{ProgressBar, ProgressStyle};

use super::report::{ExecutionReport, ReportError, ReportItem};
use crate::catalog::model::InstallMethod;
use crate::planner::plan::{ActionType, InstallPlan, PlannedAction};

pub fn find_dotfiles_root() -> PathBuf {
    if let Ok(dir) = env::var("DOTFILES_DIR") {
        let p = PathBuf::from(dir);
        if p.exists() {
            return p;
        }
    }

    if let Ok(current) = env::current_dir() {
        if current.join("scripts").is_dir() && current.join("shell").is_dir() {
            return current;
        }
        if let Some(parent) = current.parent() {
            if parent.join("scripts").is_dir() && parent.join("shell").is_dir() {
                return parent.to_path_buf();
            }
        }
    }

    if let Ok(home) = env::var("HOME") {
        let p = PathBuf::from(home).join("personal-projects/dotfiles");
        if p.exists() {
            return p;
        }
    }

    PathBuf::from(".")
}

pub fn execute_plan(plan: &InstallPlan, dry_run: bool) -> Result<ExecutionReport> {
    let mut report = ExecutionReport::new();
    let root = find_dotfiles_root();

    if dry_run {
        println!("\n{}", "--- DRY-RUN MODE (No system modifications will be made) ---".yellow().bold());
        for action in &plan.actions {
            println!(" [DRY-RUN] Would execute {:?} for {}", action.install_method, action.tool_name);
            report.successes.push(ReportItem {
                tool_name: action.tool_name.clone(),
                message: format!("[DRY-RUN] {}", action.summary),
            });
        }
        return Ok(report);
    }

    let total = plan.actions.len();
    if total == 0 {
        return Ok(report);
    }

    println!("\n{}", "Executing approved actions...".bold().cyan());

    let pb = ProgressBar::new(total as u64);
    pb.set_style(
        ProgressStyle::default_bar()
            .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} {msg}")
            .expect("Valid progress template")
            .progress_chars("#>-"),
    );

    for (idx, action) in plan.actions.iter().enumerate() {
        pb.set_message(format!("{}: {}", action.tool_name, action.summary));

        let res = execute_action(action, &root);
        match res {
            Ok(msg) => {
                if action.action_type == ActionType::VerifyOrSync && msg.contains("Already installed") {
                    report.skips.push(ReportItem {
                        tool_name: action.tool_name.clone(),
                        message: msg,
                    });
                } else {
                    report.successes.push(ReportItem {
                        tool_name: action.tool_name.clone(),
                        message: msg,
                    });
                }
            }
            Err(e) => {
                report.errors.push(ReportError {
                    tool_name: action.tool_name.clone(),
                    error: format!("{:#}", e),
                });
            }
        }

        pb.set_position((idx + 1) as u64);
    }

    pb.finish_with_message("Execution complete");
    Ok(report)
}

fn execute_action(action: &PlannedAction, root: &Path) -> Result<String> {
    match &action.install_method {
        InstallMethod::Script(script_rel) => {
            let script_path = root.join(script_rel);
            if !script_path.exists() {
                anyhow::bail!("Installer script not found: {}", script_path.display());
            }

            let status = Command::new("bash")
                .arg(&script_path)
                .status()
                .with_context(|| format!("Failed to run script {}", script_path.display()))?;

            if !status.success() {
                anyhow::bail!("Script exited with non-zero status code: {:?}", status.code());
            }
            Ok(format!("Script '{}' finished successfully", script_rel))
        }

        InstallMethod::AiAdapter(adapter_rel) => {
            let adapter_path = root.join(adapter_rel);
            if !adapter_path.exists() {
                anyhow::bail!("AI adapter script not found: {}", adapter_path.display());
            }

            let status = Command::new("bash")
                .arg(&adapter_path)
                .status()
                .with_context(|| format!("Failed to run adapter {}", adapter_path.display()))?;

            if !status.success() {
                anyhow::bail!("Adapter exited with code: {:?}", status.code());
            }
            Ok(format!("Synchronized adapter '{}'", adapter_rel))
        }

        InstallMethod::AptPackage(pkg) => {
            let status = Command::new("sudo")
                .args(["apt-get", "install", "-y", pkg])
                .status()
                .with_context(|| format!("Failed to install APT package {}", pkg))?;

            if !status.success() {
                anyhow::bail!("apt-get install failed for {}", pkg);
            }
            Ok(format!("Installed APT package '{}'", pkg))
        }

        InstallMethod::SnapPackage { name, classic } => {
            let mut cmd = Command::new("sudo");
            cmd.args(["snap", "install", name]);
            if *classic {
                cmd.arg("--classic");
            }
            let status = cmd.status().with_context(|| format!("Failed to install snap {}", name))?;
            if !status.success() {
                anyhow::bail!("snap install failed for {}", name);
            }
            Ok(format!("Installed Snap package '{}'", name))
        }

        InstallMethod::ShellCommand(cmd_str) => {
            let status = Command::new("bash")
                .args(["-c", cmd_str])
                .status()
                .with_context(|| format!("Failed to run shell command: {}", cmd_str))?;

            if !status.success() {
                anyhow::bail!("Command failed: {}", cmd_str);
            }
            Ok(format!("Ran command '{}'", cmd_str))
        }
    }
}
