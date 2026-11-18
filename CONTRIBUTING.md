# Contributing

## Rules of a template

`test/check_templates.sh` checks each rule that a script can check.

### Granularity

- A job template, `jobs/<name>.yml`, is what a pipeline uses.
- A step template comes only when a second job template needs the same steps.
- A pipeline adds its own steps through a `stepList` parameter, and its variables through `variables:`.

### Parameters

- Each parameter has a `type` and a `displayName`, and its name is in camel case.
- A parameter has `values:` when its values are known, so Azure stops a wrong value before the run starts.
- A parameter is never written in a script, as Azure pastes it into the shell code.
  The step gives it in `env:`, and the script reads `"$VARIABLE"`.

### Jobs and steps

- Each job sets `timeoutInMinutes`.
- Each script step sets `target.settableVariables: none`, so the code it runs cannot change a variable a later step reads.
- Each checkout sets `persistCredentials: false`.
- A job runs on a pool given by a parameter, `vmImage: ubuntu-latest` by default.

### Tools

- No third party container images are to be used, except the `devpro/ubuntu-*` ones.
- A tool comes from a task of Microsoft, or from its official release at a fixed version, and its SHA256 is checked before use.
- A package comes from a list of hashes, as with `pip install --require-hashes`.

## Test a template

1. Use it in `azure-pipelines.yml` by its path, on a fixture in `test/fixtures` when it needs code to run on.
   A fixture that passes only when the parameters reach the job proves they do.
2. Add a section to `docs/templates.md`, with a usage example and the parameters.

A parameter that no job can test is listed in `UNTESTED_PARTS` of `test/check_templates.sh`, with the reason.

## Check locally

IstarCI runs `azure-pipelines.yml` on every commit, and `istarci wait` gives the result of `HEAD`.

## Release

A tag with a semantic version and no `v` prefix, `1.2.3` for example, is what a pipeline reads.
A new parameter with a default is a minor version, and a removed or renamed parameter or job is a major version.
