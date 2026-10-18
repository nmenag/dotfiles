use dotctl::catalog::model::Category;
use dotctl::catalog::registry::{all_tools, find_tool, tools_by_category};

#[test]
fn test_catalog_completeness() {
    let tools = all_tools();
    assert!(!tools.is_empty(), "Catalog must not be empty");

    // Ensure every category has at least one registered tool
    for cat in Category::all() {
        let in_cat = tools_by_category(*cat);
        assert!(
            !in_cat.is_empty(),
            "Category '{}' must have registered tools in catalog",
            cat.display_name()
        );
    }

    // Ensure specific core tools exist
    assert!(find_tool("brave").is_some(), "Brave must be in catalog");
    assert!(find_tool("chrome").is_some(), "Chrome must be in catalog");
    assert!(find_tool("cursor").is_some(), "Cursor must be in catalog");
    assert!(find_tool("firefox").is_none(), "Firefox should not be in catalog");
    assert!(find_tool("claude").is_some(), "Claude must be in catalog");
    assert!(find_tool("opencode").is_some(), "OpenCode must be in catalog");
    assert!(find_tool("codex").is_some(), "Codex must be in catalog");
    assert!(find_tool("kilo").is_some(), "Kilo must be in catalog");
    assert!(find_tool("agy").is_some(), "Agy must be in catalog");
    assert!(find_tool("pi").is_some(), "Pi must be in catalog");
    assert!(find_tool("skills").is_some(), "skills CLI must be in catalog");
    assert!(find_tool("orca").is_some(), "Orca must be in catalog");
    assert!(find_tool("pgadmin").is_some(), "pgAdmin must be in catalog");
    assert!(find_tool("mongocompass").is_some(), "MongoCompass must be in catalog");
    assert!(find_tool("mise").is_some(), "Mise must be in catalog");
}

#[test]
fn test_category_filtering() {
    let browsers = tools_by_category(Category::Browsers);
    assert!(!browsers.is_empty(), "Browsers category must not be empty");
    for tool in browsers {
        assert_eq!(tool.category, Category::Browsers);
    }

    let ai_tools = tools_by_category(Category::AiAssistants);
    assert!(ai_tools.len() >= 6, "Must have at least 6 AI tools registered");
    for tool in ai_tools {
        assert_eq!(tool.category, Category::AiAssistants);
    }
}

#[test]
fn test_find_tool_case_insensitivity() {
    assert!(find_tool("brave").is_some());
    assert!(find_tool("BRAVE").is_some());
    assert!(find_tool("Brave").is_some());
    assert!(find_tool("nonexistent_tool_xyz").is_none());
}
