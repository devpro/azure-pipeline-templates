# Templates

## dotnet-quality

Lints, builds and tests .NET code.

> [!NOTE]
> The test results go to the Tests tab of the run, and the coverage to its Code Coverage tab.

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

Example with a variable:

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
