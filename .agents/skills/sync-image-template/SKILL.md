---
name: sync-image-template
description: Sync this Ammix bootc image repository with the ublue-os/image-template Git remote while preserving intentional Ammix build behavior. Use when fetching or merging template/main, resolving upstream-template conflicts, reviewing Containerfile or GitHub Actions build changes, keeping the Justfile exactly upstream, or validating and publishing an upstream sync.
---

# Sync Image Template

Keep Ammix's image contents intentional while adopting upstream build infrastructure with minimal divergence.

## Before changing anything

Read [references/ammix-policy.md](references/ammix-policy.md) completely. Treat it as the repository-specific merge contract.

Inspect the clean working tree, current branch, remotes, and `template/main`. Restore a missing `template` remote as `https://github.com/ublue-os/image-template.git`, then fetch all remotes.

## Merge workflow

1. Create a temporary local review branch for a broad sync unless the user explicitly requests a direct merge.
2. Run `git merge template/main --allow-unrelated-histories`.
3. Stop at unresolved conflicts. Explain each local/upstream difference and ask the user what to keep before resolving it.
4. Apply the decisions in [references/ammix-policy.md](references/ammix-policy.md). Keep the root `Justfile` byte-for-byte equal to `template/main:Justfile`; place Ammix values in `image-template.env`, not in the Justfile.
5. Inspect non-conflicting upstream additions too. Do not restore disk workflows or configuration merely because the exact upstream Justfile contains recipes for them.

Never rewrite `main` history. Do not resolve conflicts by deleting user changes that were not placed in scope.

## Validation

Use the merged upstream Justfile's canonical workflow:

1. Run `just fix` and `just format`.
2. Run `just check` and `just lint`.
3. Confirm the root Justfile matches `template/main:Justfile` after formatting with `git diff --exit-code template/main -- Justfile`.
4. Confirm no unmerged paths or conflict markers remain. Run `git diff --check -- . ':(exclude)Justfile'`; upstream may carry whitespace that must remain unchanged for exact parity.

Never invoke `just clean`; the exact upstream recipe uses destructive removal commands forbidden by this repository's instructions. Do not run a local image build unless the user requests it; CI image builds are expensive. Before committing or pushing, confirm whether the commit should trigger CI or include `[skip ci]`.

## Handoff

Report the upstream commit merged, conflict decisions, intentional deviations from upstream, validation results, commit, branch, and push status. After validation, fast-forward local `main` from the review branch and push normally when requested. Do not open a pull request unless the user asks for one.
