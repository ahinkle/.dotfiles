# Review Branch for Pull Request

Review the current branch as a proposed pull request. This is a code review focused on catching issues that matter.

## Context Gathering

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

## Review Philosophy

You are reviewing code with these principles in mind:

### Style & Architecture
- **Taylor Otwell style**: Elegant, simplistic, and clean code
- **No comments**: Code should be self-documenting. Comments are only acceptable for genuinely complex logic that cannot be simplified. Flag any unnecessary comments.
- **Leverage Laravel**: Prefer Laravel's built-in features over custom action classes. Laravel provides most of what you need—don't reinvent the wheel
- **Convention consistency**: Match existing conventions in the codebase. If deviating from convention, flag whether ALL touchpoints should be updated to the new pattern (consistency matters more than which pattern)

### What to Flag (Priority Order)

**Critical Issues:**
1. **Security concerns** - SQL injection, XSS, mass assignment vulnerabilities, exposed secrets
2. **Performance problems** - N+1 queries, unnecessary loops, missing indexes, eager loading issues
3. **Magic strings** - Unacceptable. Constants, enums, or config values should be used instead
4. **Breaking changes** - Unintended side effects or breaking existing functionality

**Important Issues:**
5. **Convention violations** - Code that doesn't match established patterns in the codebase
6. **Long methods** - Methods doing too much that should be broken down. Suggest abstraction but don't prescribe exact names
7. **Missing tests** - Feature tests for new functionality. NOT testing framework behavior (don't test every validation rule). Focus on custom business logic and important flows
8. **Unnecessary comments** - Flag ALL comments unless they explain genuinely complex logic. Code should speak for itself. We typically never write comments.
9. **PHPStan ignores/baseline additions** - Strongly discourage `@phpstan-ignore` annotations or adding to the PHPStan baseline. Only acceptable if fixing would require enormous overhead or modifying vendor packages.

**Minor Issues:**
10. **Typos** - In code or strings
11. **Messy/hard-to-read code** - Confusing logic, poor formatting, unnecessary complexity
12. **Poor naming** - For variables, methods, classes. Phrase these as *questions* rather than prescriptive corrections (e.g., "Does this name fully capture what this method does?" rather than "Rename this to X")

### What NOT to Flag
- Superfluous tests already written; these are okay to have.

### Do NOT Run
- **Tests**: Only run tests if you make changes that need verification. Otherwise, assume tests are passing.


### Fix Silently (Flag but Don't Comment in PR)
These are valid issues to identify, but ones you'll go ahead and fix rather than requesting changes:
- Minor stylistic inconsistencies
- Naming improvements (variables, methods, classes)
- Small readability tweaks

## Output Format

Provide a prioritized list of findings:

### Summary
One sentence: Is this PR ready to merge, or are there blockers?

### Issues Found (if any)

List issues in priority order. For each issue:
- **File:line** - Brief description
- Why it matters
- Suggested approach (not prescriptive code unless helpful)

Group by severity:
1. 🚨 **Must Fix** - Blockers that should be resolved before merge
2. ⚠️ **Should Fix** - Important issues worth addressing
3. 💡 **Consider** - Suggestions and questions for improvement

### Testing Gaps (if any)
Note any missing feature tests for new business logic. Be specific about what scenarios need coverage.

### Conventions
Note if new patterns are introduced. Ask: should existing code be updated to match, or should this PR align with existing patterns?

### Verdict
- ✅ **Good to merge** - No blockers found
- 🔄 **Needs changes** - List the must-fix items
- ❓ **Needs discussion** - Flag architectural decisions that need team input
