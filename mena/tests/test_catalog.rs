use mena::catalog::model::Category;
use mena::catalog::registry::{all_tools, find_tool, tools_by_category};

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
    assert!(find_tool("dbgate").is_some(), "DbGate must be in catalog");
    assert_eq!(find_tool("dbgate").unwrap().category, Category::Databases);
    assert!(find_tool("dbeaver").is_some(), "DBeaver must be in catalog");
    assert_eq!(find_tool("dbeaver").unwrap().category, Category::Databases);
    assert_eq!(find_tool("pgadmin").unwrap().category, Category::Databases);
    assert_eq!(find_tool("mongocompass").unwrap().category, Category::Databases);
    assert!(find_tool("asdf").is_some(), "ASDF must be in catalog");
    assert_eq!(find_tool("asdf").unwrap().category, Category::VersionManagers);
    assert!(find_tool("mise").is_some(), "Mise must be in catalog");
    assert_eq!(find_tool("mise").unwrap().category, Category::VersionManagers);
    assert!(find_tool("git").is_some(), "Git must be in catalog");
    assert_eq!(find_tool("git").unwrap().category, Category::CliTools);
    assert!(find_tool("docker").is_some(), "Docker must be in catalog");
    assert_eq!(find_tool("docker").unwrap().category, Category::CliTools);
    assert!(find_tool("ohmyzsh").is_some(), "Oh My Zsh must be in catalog");
    assert_eq!(find_tool("ohmyzsh").unwrap().category, Category::CliTools);
    assert!(find_tool("shell-dotfiles").is_some(), "Shell dotfiles must be in catalog");
    assert_eq!(find_tool("shell-dotfiles").unwrap().category, Category::CliTools);

    // Desktop programs & API clients
    assert!(find_tool("bleachbit").is_some(), "BleachBit must be in catalog");
    assert_eq!(find_tool("bleachbit").unwrap().category, Category::Programs);
    assert!(find_tool("flameshot").is_some(), "Flameshot must be in catalog");
    assert_eq!(find_tool("flameshot").unwrap().category, Category::Programs);
    assert!(find_tool("vlc").is_some(), "VLC must be in catalog");
    assert_eq!(find_tool("vlc").unwrap().category, Category::Programs);
    assert!(find_tool("postman").is_some(), "Postman must be in catalog");
    assert_eq!(find_tool("postman").unwrap().category, Category::Programs);
    assert!(find_tool("bruno").is_some(), "Bruno must be in catalog");
    assert_eq!(find_tool("bruno").unwrap().category, Category::Programs);
    assert!(find_tool("stacer").is_some(), "Stacer must be in catalog");
    assert_eq!(find_tool("stacer").unwrap().category, Category::Programs);
}

#[test]
fn test_wizard_categories_excludes_core_cli() {
    let wizard_cats = Category::wizard_categories();
    assert!(
        !wizard_cats.contains(&Category::CliTools),
        "Wizard categories must not contain CliTools (core tools are mandatory/auto-installed)"
    );
    assert!(
        wizard_cats.contains(&Category::Programs),
        "Wizard categories must contain Programs"
    );
    assert!(Category::CliTools.is_core());
    assert!(!Category::Programs.is_core());
    assert!(!Category::Browsers.is_core());
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

    let db_tools = tools_by_category(Category::Databases);
    assert_eq!(db_tools.len(), 4, "Must have exactly 4 database tools registered");
    for tool in &db_tools {
        assert_eq!(tool.category, Category::Databases);
    }
    let db_ids: Vec<&str> = db_tools.iter().map(|t| t.id).collect();
    assert!(db_ids.contains(&"pgadmin"));
    assert!(db_ids.contains(&"mongocompass"));
    assert!(db_ids.contains(&"dbgate"));
    assert!(db_ids.contains(&"dbeaver"));
}

#[test]
fn test_find_tool_case_insensitivity() {
    assert!(find_tool("brave").is_some());
    assert!(find_tool("BRAVE").is_some());
    assert!(find_tool("Brave").is_some());
    assert!(find_tool("nonexistent_tool_xyz").is_none());
}

#[test]
fn test_install_core_cli_parsing() {
    use clap::Parser;
    use mena::cli::{Cli, Commands};

    let parsed = Cli::try_parse_from(["mena", "install", "core"]).expect("Should parse 'mena install core'");
    match parsed.command {
        Some(Commands::Install { category, core, dry_run, yes }) => {
            assert_eq!(category.as_deref(), Some("core"));
            assert!(!core);
            assert!(!dry_run);
            assert!(!yes);
        }
        _ => panic!("Expected Commands::Install with category 'core'"),
    }

    let parsed_dry = Cli::try_parse_from(["mena", "install", "core", "--dry-run"]).expect("Should parse 'mena install core --dry-run'");
    match parsed_dry.command {
        Some(Commands::Install { category, dry_run, .. }) => {
            assert_eq!(category.as_deref(), Some("core"));
            assert!(dry_run);
        }
        _ => panic!("Expected Commands::Install with dry_run true"),
    }
}
