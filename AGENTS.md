# azure-pipeline-templates: agent context

Templates for pipelines in Azure DevOps.

## Reference

- `../github-workflow-parts` is the reference model, apart from the differences between GitHub and Azure DevOps.
  Its rules apply here: no third-party container image, tools from official releases with a checked SHA256, the most secure settings, a test for each part,
  and the right granularity.
  `../gitlab-components` is the implementation for GitLab and may have additional lessons learned.
- Before a design, the current Azure DevOps documentation and best practices on the internet are read, to get the best in class.
- The components are validated on the repositories of this machine (`istarci list`, chade), which are mainly GitHub repositories.
- IstarCI runs each commit as a merge request pipeline, so the workflow rules are not changed for it.
- On a repository whose `.istarci.yml` reads another provider, `istarci run --provider gitlab <sha>` runs the GitLab pipeline,
  and `istarci wait <sha> --provider gitlab` gives its result.
  `workflow.provider` of that repository is never changed for a validation.
- This work also makes sure IstarCI runs Azure DevOps pipelines correctly.
  A gap or a bug of IstarCI is never worked around here: the agent writes a prompt and gives it to the user,
  and never sends it to the IstarCI session itself.

## Working rules

- **Every command runs in the foreground, and the agent waits for it.**
  No background commands, no subagents, no forks, no parallel tasks, even for a long commands.
  If a command runs more than 10 minutes, then there is an issue and it's much efficient to do active waits with checks.
- Headers stay: short documentation still has sections.
- Linters for YAML and Markdown are never run by an agent.
- Markdown files are formatted with `node ../neatmd/bin/cli.js <file>`, and the agent reads the diff it makes.
- Commit only when asked, only create a feature branch if the local checkout is on main, and never push.
  Shell scripts are `snake_case` and committed with the executable bit (`git update-index --chmod=+x`).
- Documentation and comments are as short as possible.
- `istarci` runs on every commit and is used to check locally the pipelines before pushing git commits.

## Writing style

Applies to Markdown, code comments, commit messages and prose in scripts.

- **A comment says why, not what, and the why is timeless.**
  Code comments are not common sentences, it says directly what the code does, ideally short, starting with a lower case verb.
- **One thought per line.**
  Every sentence starts on its own line.
  A sentence that would pass 180 characters is cut where a reader would take a breath,
  at a comma or before a "so", an "and" or a "which", and never inside a phrase.
- **No em dash, no en dash.**
  A colon, a comma, or a full stop.
- **No second person.**
  "The working tree", not "your working tree"; `<token>`, not `<your-token>`.
- Always write for humans, use ASD Simplified Technical English (ASD-STE100)
