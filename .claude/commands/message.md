---
description: "Generate a commit message from staged changes (git diff --cached)"
allowed-tools: ["Bash"]
---

Analyze the staged changes and generate an appropriate commit message:

!git diff --cached

Based on the staged changes above, generate a concise commit message that:
1. Follows conventional commit format if applicable
2. Summarizes the nature of changes (add, update, fix, refactor, etc.)
3. Focuses on the "why" rather than the "what" 
4. Is 1-2 sentences maximum
5. Uses present tense, imperative mood

If no staged changes are found, suggest staging files first with `git add`.