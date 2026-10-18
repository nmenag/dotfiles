use colored::Colorize;

#[derive(Debug, Clone)]
pub struct ReportItem {
    pub tool_name: String,
    pub message: String,
}

#[derive(Debug, Clone)]
pub struct ReportError {
    pub tool_name: String,
    pub error: String,
}

#[derive(Debug, Default, Clone)]
pub struct ExecutionReport {
    pub successes: Vec<ReportItem>,
    pub skips: Vec<ReportItem>,
    pub errors: Vec<ReportError>,
}

impl ExecutionReport {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn print_summary(&self) {
        println!("\n{}", "==================== EXECUTION REPORT ====================".bold().cyan());

        // 1. Successes
        println!("\n{}: ({})", "✓ Completed Actions".green().bold(), self.successes.len());
        if self.successes.is_empty() {
            println!("   (None)");
        } else {
            for item in &self.successes {
                println!("   {} {:<24} -> {}", "✓".green().bold(), item.tool_name.bold(), item.message.dimmed());
            }
        }

        // 2. Skips
        if !self.skips.is_empty() {
            println!("\n{}: ({})", "ℹ Omitted / Already Up-To-Date".blue().bold(), self.skips.len());
            for item in &self.skips {
                println!("   {} {:<24} -> {}", "ℹ".blue().bold(), item.tool_name, item.message.dimmed());
            }
        }

        // 3. Errors
        if !self.errors.is_empty() {
            println!("\n{}: ({})", "✗ Failed Actions".red().bold(), self.errors.len());
            for err in &self.errors {
                println!("   {} {:<24} -> {}", "✗".red().bold(), err.tool_name.bold(), err.error.red());
            }
        }

        println!("\n{}", "==========================================================".cyan());

        if self.errors.is_empty() {
            println!("{} All selected components are ready! Run '{}' to audit your environment.",
                "SUCCESS:".green().bold(),
                "dotctl doctor".cyan().bold()
            );
        } else {
            println!("{} {} action(s) encountered errors. Check logs and run '{}' for diagnostics.",
                "WARNING:".yellow().bold(),
                self.errors.len(),
                "dotctl doctor".cyan()
            );
        }
    }
}
