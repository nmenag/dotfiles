use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(
    name = "mena",
    author = "Nicolas Mena <nmena.garzon@gmail.com>",
    version,
    about = "DevEx CLI workstation & dotfiles management assistant for Linux",
    long_about = "mena provides an interactive, safe, and idempotent workstation installer, \
diagnostics, and synchronization engine for developers on Debian/Ubuntu and derivatives."
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Launch the interactive installation wizard (all categories or filtered by category)
    Install {
        /// Optional category to filter (e.g., 'browser', 'programs', 'runtimes', 'dev', 'ai', 'skills', 'shell')
        #[arg(value_name = "CATEGORY")]
        category: Option<String>,

        /// Run in dry-run mode without executing installations
        #[arg(long, short = 'd')]
        dry_run: bool,

        /// Automatically approve installation of missing components non-interactively
        #[arg(long, short = 'y')]
        yes: bool,
    },

    /// List all cataloged workstation tools, categories, and installation status
    List {
        /// Filter tools by category (e.g., 'browser', 'programs', 'runtimes', 'dev', 'ai', 'skills', 'shell')
        #[arg(long, short = 'c')]
        category: Option<String>,

        /// Export tool catalog as formatted JSON
        #[arg(long)]
        json: bool,
    },

    /// Run comprehensive workstation and environment diagnostics
    Doctor,

    /// Update AI agent adapters, shell frameworks, and package lists
    Update,
}
