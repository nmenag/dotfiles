use std::fs;
use std::path::Path;
use std::process::Command;

use anyhow::Result;
use colored::Colorize;

use crate::executor::runner::find_dotfiles_root;
use crate::system::detector::SystemInfo;
use crate::system::package::{command_path, home_path_exists};

pub fn handle_doctor(system: &SystemInfo) -> Result<()> {
    let root = find_dotfiles_root();

    println!("\n{}", "=== dotctl Workstation Diagnostic (Doctor) ===".bold().cyan());

    // 1. Operating System & Hardware
    println!("\n{}:", "1. Operating System & Platform".bold());
    println!("   {} OS:              {} ({})", "•".cyan(), system.os_name.bold(), system.codename);
    println!("   {} Distro ID:       {}", "•".cyan(), system.distro_id);
    println!("   {} Architecture:    {}", "•".cyan(), system.arch);
    println!("   {} User:            {}", "•".cyan(), system.current_user);
    println!("   {} Active Shell:    {}", "•".cyan(), system.shell);
    println!("   {} Dotfiles Root:   {}", "•".cyan(), root.display().to_string().cyan());

    // 2. Package Managers
    println!("\n{}:", "2. Package Managers Availability".bold());
    print_pkg_manager("APT Package Manager (apt-get)", system.has_apt);
    print_pkg_manager("Snap Package Manager (snap)", system.has_snap);
    print_pkg_manager("Rust Cargo Toolchain (cargo)", system.has_cargo);
    print_pkg_manager("ASDF Runtime Manager (asdf)", system.has_asdf);
    print_pkg_manager("Mise Version Manager (mise)", system.has_mise);
    print_pkg_manager("Node Package Manager (npm)", system.has_npm);
    print_pkg_manager("Node Executable Runner (npx)", system.has_npx);

    // 3. Shell Dotfiles Integration
    println!("\n{}:", "3. Shell Dotfiles Configuration".bold());
    check_shell_file(".bashrc", "shell/bashrc.sh");
    check_shell_file(".zshrc", "shell/zshrc.sh");
    if home_path_exists(".oh-my-zsh") {
        println!("   {} Oh My Zsh is installed at ~/.oh-my-zsh", "✓".green().bold());
    } else {
        println!("   {} Oh My Zsh is not found at ~/.oh-my-zsh (Run 'dotctl install shell')", "○".yellow().bold());
    }

    // 4. AI Coding Assistants
    println!("\n{}:", "4. AI Assistants & Adapters".bold());
    let ai_tools = [
        ("claude", "Claude Code", ".claude/CLAUDE.md"),
        ("opencode", "OpenCode", ".config/opencode/AGENTS.md"),
        ("codex", "Codex CLI", ".codex/AGENTS.md"),
        ("kilo", "Kilo CLI", ".config/kilo/AGENTS.md"),
        ("agy", "Agy (Antigravity)", ".gemini/GEMINI.md"),
        ("pi", "Pi Coding Agent", ".pi/agent/AGENTS.md"),
    ];

    for (cmd, name, rel_adapter) in ai_tools {
        let is_cli = command_path(cmd).is_some();
        let is_adapter = home_path_exists(rel_adapter);

        let cli_badge = if is_cli {
            format!("[CLI: ✓]").green()
        } else {
            format!("[CLI: missing]").yellow()
        };

        let adapter_badge = if is_adapter {
            format!("[Adapter: ✓]").green()
        } else {
            format!("[Adapter: missing]").red()
        };

        println!("   {} {:<20} {:<16} {:<18} (~/{})", "•".cyan(), name.bold(), cli_badge, adapter_badge, rel_adapter.dimmed());
    }

    // Official skills CLI check
    if command_path("skills").is_some() {
        println!("   {} {:<20} {:<16} (Official Agent Skills CLI installed)", "✓".green().bold(), "skills CLI", "[CLI: ✓]".green());
    } else if system.has_npx {
        println!("   {} {:<20} {:<16} (Available via 'npx skills')", "ℹ".blue().bold(), "skills CLI", "[Via NPX]".blue());
    } else {
        println!("   {} {:<20} {:<16} (Install via 'npm install -g skills')", "○".yellow().bold(), "skills CLI", "[Missing]".yellow());
    }

    // 5. Security & Secret Hygiene
    println!("\n{}:", "5. Environment & Secret Hygiene".bold());
    let env_file = root.join(".env");
    let env_sample = root.join(".env.sample");

    if env_sample.exists() {
        println!("   {} .env.sample template exists", "✓".green().bold());
    } else {
        println!("   {} .env.sample template is missing", "✗".red().bold());
    }

    if env_file.exists() {
        let git_ignored = Command::new("git")
            .args(["-C", root.to_str().unwrap_or("."), "check-ignore", "-q", ".env"])
            .status()
            .map(|s| s.success())
            .unwrap_or(false);

        if git_ignored {
            println!("   {} Local .env file exists and is strictly ignored by Git", "✓".green().bold());
        } else {
            println!("   {} SECURITY ALERT: .env exists but is NOT ignored by Git!", "✗".red().bold());
        }
    } else {
        println!("   {} No local .env file found (copy .env.sample to configure USERNAME/EMAIL)", "ℹ".blue().bold());
    }

    println!("\n{}", "==========================================================".cyan());
    println!("Doctor diagnostic complete.\n");
    Ok(())
}

fn print_pkg_manager(name: &str, available: bool) {
    if available {
        println!("   {} {:<32} {}", "✓".green().bold(), name, "[Available]".green());
    } else {
        println!("   {} {:<32} {}", "○".yellow().bold(), name, "[Not Found]".yellow());
    }
}

fn check_shell_file(dotfile_rel: &str, target_script: &str) {
    if let Ok(home) = std::env::var("HOME") {
        let path = Path::new(&home).join(dotfile_rel);
        if path.exists() {
            let content = fs::read_to_string(&path).unwrap_or_default();
            if content.contains(target_script) || content.contains("DOTFILES_DIR") {
                println!("   {} ~/{} properly links to repository ({})", "✓".green().bold(), dotfile_rel, target_script.dimmed());
                return;
            } else {
                println!("   {} ~/{} exists but does not load dotfiles ({})", "○".yellow().bold(), dotfile_rel, target_script.dimmed());
                return;
            }
        }
    }
    println!("   {} ~/{} does not exist", "○".yellow().bold(), dotfile_rel);
}
