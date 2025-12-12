# Provide a Pull Request Title and Description

Review the current branch as a proposed pull request and suggest an appropriate title and description based on the changes made then open a new tab with the suggested title and description filled in using the GitHub CLI.

## Context Gathering

**Note**: This command assumes no PR exists for the current branch. Step 2 checks for an existing PR—if one is found, inform the user and provide the PR URL instead of proceeding with creation.

1. First, determine the default branch (main or master):
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
   ```

2. Get the current branch name and check for an existing PR:
   ```bash
   git branch --show-current
   gh pr view --json title,body,url 2>/dev/null || echo "No PR exists yet"
   ```

3. Get the diff against the default branch:
   ```bash
   git diff $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")...HEAD
   ```

4. List changed files:
   ```bash
   git diff --name-only $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")...HEAD
   ```

5. Once you have gathered the context, use it to generate a concise and informative PR title and description following the guidelines below. Finally, open a new tab with the suggested title and description filled in using the GitHub CLI:
   ```bash
   gh pr create --web --title "YOUR_GENERATED_TITLE" --body "$(cat <<'EOF'
   YOUR_GENERATED_DESCRIPTION
   EOF
   )"
   ```

6. Replace `YOUR_GENERATED_TITLE` and `YOUR_GENERATED_DESCRIPTION` with the title and description you generated based on the context gathered. The heredoc pattern safely handles special characters, newlines, and quotes in the description.

7. The expectation from here is that it would open a new tab and the user would manually review and submit the PR.

## PR Title and Description Philosophy

You are generating a PR title and description with these principles in mind:

### Title Guidelines
- **Concise and Descriptive**: Summarize the main change in 5-10 words but be precise enough to convey the purpose.
- **Use Imperative Mood**: Start with a verb (e.g., "Add", "Fix", "Update").
- **Avoid Jargon**: Use clear language that anyone on the team can understand.
- **Highlight Impact**: If applicable, indicate the area affected (e.g., "API", "UI", "Database").

### Description Guidelines

- **Summary of Changes**: Provide a brief overview of the previous state and what has changed. Always start with "This PR..." to maintain consistency.

- **Motivation**: Explain why these changes were necessary.

Be brief but informative. Do not provide excessive detail; focus on the key points that reviewers need to understand the purpose and impact of the changes.

- **Implementation Details**: Do not go into deep technical details. Only include information that is crucial for understanding the change. Only mention significant architectural decisions or patterns. The diff should imply most implementation details rather than stating them explicitly.

- **Format**: Do not use bullet points or numbered lists. Write in clear, concise sentences and paragraphs. Use the `code` format for any code references to classes, variables, methods, or other technical terms. Do not use the full qualifying namespace unless necessary for clarity.

- **Wording/phrasing choices**: Use neutral language and don't use intensifier or qualifier terms like "obviously", "simply", "enhances", "cleanly" or "elegantly" to name a few. Additionally, avoid adding implied information the reader can infer. For example, instead of "Previously, the API was publicly accessible, which posed significant risks", use “Previously, the API was publicly accessible” as it is sufficient as the user can infer the risks between the before and after states.

- **Testing**: Do not mention testing details unless there is something unusual or noteworthy that was an integral part of the change. It should be implied that tests are included to support the changes and mentioning them is superfluously verbose.

- **Related Issues/PRs**: Often with the branch title, we reference the issue number (but not always). If you find that there the given name of the branch or context implies it closes an issue, include that in the description. e.g. "Closes #123".

### PR title and Description Examples

Be precise; we should't expect any follow-up questions from the PR description. Don't include unnecessary details such as "Here is the PR title and description:" or "Based on the changes, I suggest the following title and description.", be precise and to the point.

Example 1:
**Title**: Add user authentication to API endpoints
**Description**: This PR introduces user authentication to API endpoints to prevent unauthorized access. Previously, the API was publicly accessible. Now, users must provide valid credentials to access protected resources. 

Closes #456.


Example 2:
**Title**: Fix N+1 query in OrderController
**Description**: This PR addresses an N+1 query issue in the `OrderController` that was causing performance degradation when fetching orders with their associated items. 

Closes #789.


Bad Example 1:
**Title**: Made some changes to the API
**Description**: Adds context to exceptions that bubble up and are reported for better debugging. Changes made: ChargeException now includes user ID and order ID in the exception message. This will help identify issues faster when they occur in production.

> Reason: Vague title and an overly verbose description that includes unnecessary implementation details. 

Bad example 2:
**Title**: Merges `archive` into daily reports
**Description**: This pull request introduces significant enhancements to the user activity reporting system by integrating archive file records (archive) alongside traditional reports. The changes ensure that both sources are merged, grouped, and displayed chronologically in the generated PDF reports. Additionally, the codebase is updated to support this integration, and comprehensive tests are added to verify the new functionality.

> Reason: The PR title doesn't provide business-level context. The description is overly verbose and includes unnecessary implementation details. The description mentions tests are present; this is superfluous as it should be implied. The description doesn't explain why the change was necessary. The descriptions uses several intensifiers like "significant" and "comprehensive" which are unnecessary.
