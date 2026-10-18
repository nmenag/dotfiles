use dotctl::executor::runner::execute_plan;
use dotctl::planner::plan::InstallPlan;
use dotctl::system::detector::SystemInfo;

#[test]
fn test_dry_run_executes_no_mutations() {
    let system = SystemInfo::detect();
    let selected = vec!["brave".to_string(), "git".to_string()];
    let plan = InstallPlan::build(&selected, &system);

    assert!(!plan.actions.is_empty(), "Plan should have actions");

    // Execute in dry-run mode
    let report = execute_plan(&plan, true).expect("Dry run should succeed");

    assert_eq!(report.errors.len(), 0, "Dry run should produce zero errors");
    assert_eq!(
        report.successes.len(),
        plan.actions.len(),
        "Report successes should match planned actions in dry-run"
    );

    // Verify all messages have [DRY-RUN] badge and didn't touch system
    for item in report.successes {
        assert!(
            item.message.contains("[DRY-RUN]"),
            "All messages in dry run must contain [DRY-RUN] badge"
        );
    }
}

#[test]
fn test_cancellation_produces_zero_actions() {
    let system = SystemInfo::detect();
    // Simulate user choosing 0 tools or aborting
    let selected: Vec<String> = Vec::new();
    let plan = InstallPlan::build(&selected, &system);

    assert!(plan.is_empty(), "Plan should be empty when no tools selected");
    assert_eq!(plan.actions.len(), 0);

    let report = execute_plan(&plan, false).expect("Empty plan execution should succeed without actions");
    assert_eq!(report.successes.len(), 0);
    assert_eq!(report.skips.len(), 0);
    assert_eq!(report.errors.len(), 0);
}

#[test]
fn test_only_approved_actions_are_executed() {
    let system = SystemInfo::detect();
    let selected = vec!["brave".to_string()];
    let plan = InstallPlan::build(&selected, &system);

    // Verify plan actions only correspond to brave
    assert_eq!(plan.actions.len(), 1);
    assert_eq!(plan.actions[0].tool_id, "brave");

    let report = execute_plan(&plan, true).expect("Dry-run execution should succeed");
    assert_eq!(report.successes.len(), 1);
    assert_eq!(report.successes[0].tool_name, "Brave Browser");

    // Unselected tools must NOT be present
    let action_ids: Vec<&str> = plan.actions.iter().map(|a| a.tool_id.as_str()).collect();
    assert!(!action_ids.contains(&"chrome"));
    assert!(!action_ids.contains(&"cursor"));
    assert!(!action_ids.contains(&"vscode"));
    assert!(!action_ids.contains(&"docker"));
}

