use dotctl::planner::plan::InstallPlan;
use dotctl::system::detector::SystemInfo;

#[test]
fn test_summary_matches_plan() {
    let system = SystemInfo::detect();
    let selected = vec![
        "brave".to_string(),
        "vscode".to_string(),
        "claude".to_string(),
        "skills".to_string(),
    ];

    let plan = InstallPlan::build(&selected, &system);
    let summary_raw = plan.render_summary();
    let summary = console::strip_ansi_codes(&summary_raw);

    // Verify all tool names appear in the summary
    assert!(summary.contains("Brave Browser"), "Summary must contain Brave Browser");
    assert!(summary.contains("Visual Studio Code"), "Summary must contain Visual Studio Code");
    assert!(summary.contains("Claude Code"), "Summary must contain Claude Code");
    assert!(summary.contains("Skills CLI"), "Summary must contain Skills CLI");

    // Verify sections exist in the summary
    assert!(summary.contains("PRE-INSTALLATION SUMMARY"), "Must have summary header");
    assert!(summary.contains("Planned Actions"), "Must have planned actions breakdown");

    // Action count should be reflected in summary
    assert!(
        summary.contains(&format!("4. Planned Actions: ({})", plan.actions.len())),
        "Summary action count must match plan action count. Summary was:\n{}",
        summary
    );
}

#[test]
fn test_dependency_resolution() {
    let system = SystemInfo::detect();
    // ASDF depends on git, curl, build-essential
    let selected = vec!["asdf".to_string()];
    let plan = InstallPlan::build(&selected, &system);

    assert!(!plan.actions.is_empty(), "Plan for asdf must not be empty");

    let action_tool_ids: Vec<&str> = plan.actions.iter().map(|a| a.tool_id.as_str()).collect();
    assert!(action_tool_ids.contains(&"asdf"), "Plan must include asdf");

    // If git, curl or build-essential are missing on a minimal system, they would be added.
    // In all cases, plan.selected_tools must contain asdf
    assert_eq!(plan.selected_tools[0].tool.id, "asdf");
}
