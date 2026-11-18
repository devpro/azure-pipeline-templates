# Azure Pipelines Templates

Azure Pipelines templates for code repositories.

> [!IMPORTANT]
> Keep pipelines **safe** and **DRY**!

## Overview

- A template adds jobs, and the triggers, the stages and the variables stay those of the pipeline.
- A step that runs code of the repository cannot set a variable, so a later step reads only what the pipeline gave it.
- A pipeline reads the templates at a tag of this repository, which never moves.
- `endpoint` is a GitHub service connection of the organization, which a pipeline of a GitHub repository already has.

```yaml
resources:
  repositories:
    - repository: templates
      type: github
      name: devpro/azure-pipeline-templates
      ref: refs/tags/1.0.0
      endpoint: github
```

## Templates

- [dotnet-quality](#dotnet-quality)

### dotnet-quality

Lints, builds and tests .NET code.
The test results go to the Tests tab of the run, and the coverage to its Code Coverage tab.

```yaml
jobs:
  - template: jobs/dotnet-quality.yml@templates
    parameters:
      testArgs: --report-xunit-trx --coverage --coverage-output-format cobertura
```

Parameter          | Type     | Default                  | Description
-------------------|----------|--------------------------|------------------------------------------------------------------------------------------------------
`name`             | string   | `dotnet_quality`         | Name of the job, unique in the stage
`pool`             | object   | `vmImage: ubuntu-latest` | Pool of the job
`timeoutInMinutes` | number   | `60`                     | Minutes the job runs before it is cancelled
`dotnetVersion`    | string   | `10.0.x`                 | Version of the .NET SDK
`workingDirectory` | string   | `.`                      | Directory of the solution or project, relative to the repository root
`beforeBuildSteps` | stepList | empty                    | Steps run after the restore and before the build, to start a service or install a tool the tests need
`testArgs`         | string   | empty                    | Arguments of `dotnet test` as shell words, which write the TRX and Cobertura files the run publishes

A variable the tests need is a variable of the pipeline, which Azure gives to every step:

```yaml
variables:
  Features__IsHttpsRedirectionEnabled: "false"

jobs:
  - template: jobs/dotnet-quality.yml@templates
    parameters:
      beforeBuildSteps:
        - bash: ./scripts/install_ci_tools.sh
          displayName: Install the CI tools
```

## Contribute

[CONTRIBUTING.md](CONTRIBUTING.md) tells how to add a template, test it and release it.
