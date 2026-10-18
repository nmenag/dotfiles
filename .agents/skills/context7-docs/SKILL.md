---
name: context7-docs
description: Fetches current official library, API, framework, and CLI tool documentation using the Context7 MCP server.
---

# Context7 Documentation Skill

Use this skill whenever you need to query up-to-date documentation, API specs, configuration guides, or CLI syntax for any modern library or tool.

## Execution Workflow

1. **Resolve Library ID**:
   Call the `resolve-library-id` tool with:
   - `libraryName`: Name of the tool or package (e.g. `docker`, `claude-code`, `next.js`, `asdf`).
   - `query`: A concise summary of the concept you want to look up.

2. **Select Best Match**:
   Identify the `/org/project` ID with high reputation and score.

3. **Query Documentation**:
   Call `query-docs` with:
   - `libraryId`: Selected ID.
   - `query`: Focused single-concept query (e.g. `installation and setup`, `configuration options`).

4. **Apply Findings**:
   Use the verified documentation to write code, configure dotfiles, or resolve errors.
