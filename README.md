# Azure Pipelines Templates

Templates for pipelines running in Azure DevOps.

## Overview

Avoid repeating the same lines in many repositories and get up to speed very quickly.

What the code looks like:

```yaml
resources:
  repositories:
    - repository: templates
      type: github
      name: devpro/azure-pipeline-templates
      ref: refs/tags/1.0.0
      endpoint: github
```

> [!NOTE]
> Replace `github` (endpoint) by the name of the GitHub service connection of the Azure DevOps organization.

## Templates

- [dotnet-quality](docs/templates.md#dotnet-quality)

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) to know how add a template, test it and release it.
