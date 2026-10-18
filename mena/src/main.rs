use anyhow::Result;
use clap::Parser;
use colored::Colorize;

use mena::cli::{Cli, Commands};
use mena::commands::{handle_core, handle_doctor, handle_install, handle_list, handle_update};
use mena::system::detector::SystemInfo;

fn main() -> Result<()> {
    let cli = Cli::parse();
    let system = SystemInfo::detect();

    let result = match cli.command {
        Some(Commands::Install { category, core, dry_run, yes }) => {
            if core {
                handle_core(dry_run)
            } else {
                handle_install(category, dry_run, yes, &system)
            }
        }
        Some(Commands::Core { dry_run }) => {
            handle_core(dry_run)
        }
        Some(Commands::List { category, json }) => {
            handle_list(category, json)
        }
        Some(Commands::Doctor) => {
            handle_doctor(&system)
        }
        Some(Commands::Update) => {
            handle_update()
        }
        None => {
            // Default behavior: launch full interactive wizard
            handle_install(None, false, false, &system)
        }
    };

    if let Err(err) = result {
        eprintln!("\n{} {:#}", "ERROR:".red().bold(), err);
        std::process::exit(1);
    }

    Ok(())
}
