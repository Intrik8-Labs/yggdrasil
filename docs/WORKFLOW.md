# Development Workflow

## Purpose

Develop Yggdrasil in small, understandable steps. The project owner reviews each document or capability before it is committed, published, or merged. Progress follows understanding and verification.

Work on one agreed step at a time. Finish or explicitly pause that step before starting another. Keep unrelated changes in separate branches and PRs.

## Branch roles

| Branch | Purpose | Starts from | PR target |
| --- | --- | --- | --- |
| `main` | Accepted releases | Existing branch | Receives release and hotfix PRs |
| `dev` | Approved integration work | `main` | `main` for an accepted release |
| `feature/*`, `fix/*`, `docs/*`, `chore/*` | One focused change | Current `dev` | `dev` |
| Dependent child branch | A reviewable part of a feature | Its feature branch | Its feature branch |
| `hotfix/*` | Repair an already released version | Current `main` | `main`, then synchronize into `dev` |

Start ordinary work from the latest `dev`. Keep `main` and `dev` buildable.

Use child branches only when their work depends on the parent feature. Independent changes should each start from `dev` so they can be accepted or rejected separately. Initially, use at most one child-branch level.

For example, `feature/tyr-login-validation` can target `feature/tyr-login`. The complete login feature then targets `dev`.

## Review and approval

Reading, drafting, and running checks are part of the agreed step. Approval is required before creating a commit, publishing its contents, or merging a PR.

An approval covers only the stated change and actions. One approval can cover committing and publishing together when both are explicitly included. Approval to merge into `dev` does not authorize a release into `main`.

For each step:

1. Explain the purpose, intended result, and files involved.
2. Prepare the smallest useful change on an appropriate branch.
3. Run the relevant checks and present the exact diff or complete new files.
4. Let the project owner read, question, and revise the work.
5. Commit only after explicit approval of the reviewed change.
6. Publish the approved commit when publication is authorized.
7. Have the project owner open the PR directly in GitHub.
8. Verify the proposed merge result and merge only when the owner approves it.

Wording, behavior, or scope changes after approval require renewed review and appropriate checks. Conflict resolution also needs verification.

## Verification

Report what was checked, the results, and anything that could not be checked.

| Change | Relevant verification |
| --- | --- |
| Documentation | Accuracy, readable formatting, links, and agreement with current project decisions |
| Application behavior | Meaningful tests for the behavior and failure cases, plus relevant build and architecture checks |
| Persistence or authorization | Integration checks for database behavior, workspace boundaries, and denied access |

Confirm that the diff contains only the agreed files and changes. Test results support the owner's decision; they do not replace review.

## Commits and pull requests

Use conventional commit messages with an optional scope:

- `docs: define development workflow`
- `feat(tyr): add sign-in`
- `fix(valhalla): enforce workspace access`

The project owner creates PRs directly from their GitHub account. Assistance may prepare the comparison link, title, and description.

A PR describes the resulting behavior, why it matters, and the checks actually performed. Record review comments when clarification or changes are needed. Keep unfinished published work in a draft PR.

While working solo, the owner reviews the diff and makes the merge decision. GitHub's formal approving-review requirement must account for PR authors being unable to approve their own PRs.

## Merging and defects

Squash ordinary short-lived work branches into `dev`, giving each accepted change one logical commit. A child PR may be squashed into its feature parent.

Use merge commits for `dev` release PRs into `main`. Synchronize `main` back into `dev` after a release or hotfix, preserving their shared history.

If review finds a defect, fix it on the work branch and repeat the relevant checks and review. Rejected work remains unmerged.

For an integrated defect, use a focused fix or reviewed revert. Check database and data compatibility before reverting persisted behavior. Preserve shared history; do not reset or force-push `main` or `dev` to erase mistakes.

After a merge, update the local checkout and remove the completed work branch when cleanup is approved.

## Enforcement and cadence

**Current enforcement:** manual. GitHub branch protection and automated CI checks will be configured in a separate reviewed step.

The intended protections for `main` and `dev` are required PRs, resolved discussions, relevant passing checks, and blocked force pushes and deletion. Keep automatic merging disabled.

Keep a short weekly review of completed work, blockers, and the next useful step. The cadence supports steady progress without imposing a deadline on unfinished understanding.
