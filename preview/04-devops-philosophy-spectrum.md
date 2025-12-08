# DevOps Philosophy Spectrum: From Infrastructure as Code to GitOps

Managing infrastructure through point-and-click interfaces creates invisible processes that cannot be reviewed, tested, or reliably reproduced. The "as code" paradigm addresses this by expressing infrastructure, configuration, and operational decisions as version-controlled text files. This transformation enables the same engineering practices used for application development—code review, automated testing, rollback capabilities—to apply to infrastructure management.

## The Foundation: Infrastructure as Code

**Infrastructure as Code (IaC)** treats infrastructure definitions as software artifacts rather than manual configurations. Instead of clicking through Azure Portal to create a virtual machine, an IaC approach defines that VM in a text file. The file specifies the resource type, size, network settings, and other parameters. Tools then read this definition and create the infrastructure to match.

This shift from imperative actions (click here, then click there) to declarative definitions (the infrastructure should look like this) fundamentally changes how infrastructure evolves. The definition file becomes the authoritative source. Changes happen by editing the file and reapplying it, not by modifying resources directly.

### Why Text Files Matter

Version control systems like Git track changes to text files with precision. Each modification creates a record: who changed what, when, and why. This audit trail answers questions that arise months later when investigating issues or planning migrations.

Text files also enable code review. Before infrastructure changes go live, team members can examine the proposed modifications, identify problems, and suggest improvements. This peer review catches errors before they affect production systems—a capability that manual operations lack.

Automated testing becomes possible when infrastructure exists as code. Tests can validate that configurations meet security requirements, comply with organizational policies, or follow architectural standards. These checks run automatically before changes deploy, preventing misconfigurations.

### IaC in Student Projects

Student projects encounter IaC through Bash scripts and cloud-init configurations. A Bash script that creates an Azure resource group and provisions a VM represents Infrastructure as Code. The script captures the provisioning steps as reproducible commands.

```bash
#!/bin/bash
# Figure 1: Basic infrastructure provisioning script

RESOURCE_GROUP="my-app-rg"
LOCATION="swedencentral"
VM_NAME="web-server-01"

# Create resource group
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Create virtual machine
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Ubuntu2404 \
    --size Standard_B1s \
    --generate-ssh-keys
```

This script can be committed to Git, reviewed before execution, and reused to create identical infrastructure. Modifying the script and rerunning it updates the infrastructure. The script documents the infrastructure state while also providing the mechanism to create it.

Cloud-init configurations extend this pattern. The cloud-init file defines software installation, system configuration, and service setup. When the VM boots, cloud-init applies these instructions, transforming a base Ubuntu image into a configured web server.

```yaml
# Figure 2: Cloud-init configuration for nginx installation

#cloud-config
package_update: true
packages:
  - nginx
  - python3-pip
  - postgresql-client

runcmd:
  - systemctl enable nginx
  - systemctl start nginx
```

The cloud-init file can be version controlled, reviewed, and tested. Changes to application deployment happen by modifying the cloud-init configuration, not by manually installing packages after the VM starts.

## Configuration as Code

**Configuration as Code** extends the IaC concept from infrastructure to application settings. Rather than storing configuration in a database or setting environment variables manually, configuration exists in version-controlled files that deploy alongside the application.

Application configuration determines how software behaves: database connection strings, API endpoints, feature flags, logging levels. When these settings live only in production systems, recreating environments becomes difficult. Development environments drift from production. Testing environments use different settings than production, reducing test validity.

Treating configuration as code solves these problems. Configuration files exist in the repository. Different files or sections handle different environments—development, staging, production. Deploying the application includes deploying its configuration.

### Separating Secrets from Configuration

Configuration as Code does not mean storing passwords and API keys in Git repositories. Sensitive values require different handling. The configuration file can reference secrets without containing them.

```python
# Figure 3: Configuration referencing secrets

import os

class Config:
    # Public configuration in version control
    DATABASE_HOST = "db-server.postgres.database.azure.com"
    DATABASE_NAME = "production_db"

    # Secrets loaded from environment variables
    DATABASE_PASSWORD = os.environ.get('DB_PASSWORD')
    API_KEY = os.environ.get('EXTERNAL_API_KEY')
```

The configuration file shows what secrets the application requires without exposing their values. Secret management systems like Azure Key Vault store the actual credentials. The deployment process retrieves secrets from the vault and provides them to the application as environment variables.

This separation enables version controlling the configuration structure while protecting sensitive data. The repository documents what configuration exists and how it's organized. The values for sensitive settings come from a secure secret store.

## Documentation as Code

**Documentation as Code** applies software engineering practices to documentation creation and maintenance. Documentation lives in the same repository as code, written in text-based formats like Markdown or reStructuredText. Changes to documentation follow the same workflow as code changes: edit files, commit to version control, submit for review, merge when approved.

This approach keeps documentation synchronized with code. When a developer adds a feature, the same pull request includes code changes and documentation updates. Reviewers see both together. The documentation version matches the code version.

Documentation as Code also enables automation. Documentation can be built into websites, PDFs, or other formats from source files. Tests can validate that documentation links work, code examples execute correctly, and API documentation matches actual APIs.

### Living Documentation

Traditional documentation becomes outdated because updating it requires separate effort from changing code. Developers focus on code, and documentation updates happen later—or never. Documentation as Code reduces this friction by integrating documentation into the development workflow.

```markdown
# Figure 4: Documentation alongside code in repository structure

project/
├── src/
│   ├── app.py
│   └── models.py
├── docs/
│   ├── setup.md
│   ├── api-reference.md
│   └── deployment.md
├── README.md
└── CHANGELOG.md
```

When documentation lives in the repository, it's visible during code review. A pull request that changes an API without updating the API documentation gets flagged during review. This visibility encourages keeping documentation current.

Automated tests can verify documentation accuracy. A test can extract code examples from documentation and execute them, confirming they still work. If an example breaks, the test fails, alerting the team that documentation needs updating.

## Everything as Code

The "as code" pattern extends beyond infrastructure, configuration, and documentation. **Policies**, **security rules**, and **CI/CD pipelines** can all be defined as code.

### Policy as Code

**Policy as Code** expresses organizational rules and compliance requirements as executable code. Rather than documenting policies in PDF files that humans must manually check, policies become automated tests that run against infrastructure definitions.

A policy might state: "All Azure VMs must have diagnostics enabled." As code, this becomes a test that scans infrastructure definitions and flags VMs without diagnostics configured. The test runs automatically before infrastructure changes deploy, preventing policy violations.

```python
# Figure 5: Policy validation example

def validate_vm_diagnostics(vm_config):
    """Verify VM has diagnostics enabled"""
    if 'diagnosticsProfile' not in vm_config:
        raise PolicyViolation(
            f"VM {vm_config['name']} missing diagnostics configuration"
        )
    return True
```

Policies defined as code can be version controlled, tested, and updated through the same review process as other code. When policies change, the code updates to reflect new requirements.

### Security as Code

**Security as Code** embeds security controls in automated processes. Security checks run during the development pipeline, not as a separate manual review stage.

Static analysis tools scan code for security vulnerabilities. Dependency checkers identify outdated libraries with known exploits. Configuration validators ensure security groups follow least-privilege principles. Infrastructure scanners verify encryption is enabled for data at rest and in transit.

These checks execute automatically on every commit or pull request. Developers receive immediate feedback when code introduces security issues. Security becomes part of the development workflow rather than a gatekeeper stage that delays releases.

### Pipeline as Code

**CI/CD pipelines** orchestrate building, testing, and deploying applications. Defining pipelines as code documents the deployment process while making it reproducible and reviewable.

GitHub Actions workflows, for example, exist as YAML files in the repository. The workflow defines what happens when code is pushed: run tests, build containers, deploy to staging, run integration tests, deploy to production.

```yaml
# Figure 6: GitHub Actions workflow definition

name: Deploy Application
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: pytest tests/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Azure
        run: ./scripts/deploy.sh
```

The pipeline file lives in version control. Changes to the deployment process happen through pull requests. The deployment history exists in Git history. New team members read the pipeline file to understand how releases work.

## GitOps: Git as Single Source of Truth

**GitOps** represents the endpoint of the "as code" spectrum. In a GitOps model, Git contains the complete desired state of infrastructure and applications. Automated systems continuously compare the actual state of production systems against the Git repository. When differences appear, automation reconciles them—either by updating production to match Git or by alerting that manual changes occurred.

This creates a powerful operational model. To change production, commit changes to Git. The automation detects the change and applies it. To audit production, examine Git history. To rollback a change, revert the Git commit—automation undoes the change in production.

### GitOps Workflow

A typical GitOps workflow separates the application repository from the configuration repository. Developers work in the application repository, building features and fixing bugs. When code merges to the main branch, the CI/CD pipeline builds a container image and tags it with a version number.

The configuration repository contains infrastructure definitions and deployment configurations. When a new application version is ready, a commit updates the configuration repository to reference the new image tag. The GitOps controller detects this change and deploys the new version.

```
Application Repo          Configuration Repo         Production Cluster
    (Code)                (Desired State)             (Actual State)
       |                         |                           |
    [Commit]                     |                           |
       |                         |                           |
    [Build] -----------------> [Update Image Tag]            |
                                 |                           |
                              [Commit]                       |
                                 |                           |
                           [GitOps Controller] ---------> [Deploy]
                                 |                           |
                           [Continuous Sync] <----------- [Monitor]
```

This separation means production changes always go through Git. Direct modifications to production bypass the GitOps workflow and get overwritten when the controller reconciles state. This enforces the desired state defined in Git.

### Audit Trail and Rollback

Every production change creates a Git commit. The commit shows what changed, who made the change, when it happened, and why (through the commit message). This audit trail provides complete visibility into system evolution.

Rollback becomes straightforward. If a deployment causes issues, reverting the Git commit that introduced the change triggers an automatic rollback. The GitOps controller detects that Git no longer contains the problematic change and removes it from production.

### Consistency and Disaster Recovery

GitOps ensures consistency across environments. The same Git repository can define multiple environments—development, staging, production—with different branches or directories for each. Promoting changes between environments means merging commits or updating references.

If a production environment fails completely, recovery involves pointing a new environment at the Git repository. The GitOps controller reads the desired state and recreates the infrastructure and applications to match. No manual reconstruction from memory or outdated runbooks.

## Applying the Spectrum to Student Projects

Student projects progress along this spectrum, from manual operations to increasingly codified approaches.

### Week 1-2: Manual to Scripted

Initial exercises use Azure Portal to create resources manually. This provides immediate visual feedback and builds familiarity with Azure concepts. As comfort grows, the transition to Azure CLI commands begins. Commands can be saved in text files—simple Bash scripts that capture the provisioning process.

These scripts represent the first step toward Infrastructure as Code. Rather than remembering which buttons to click, the script documents the exact commands. Running the script creates identical infrastructure. Committing the script to Git enables tracking changes over time.

### Week 2-3: Automation and Configuration

Cloud-init configurations add application-level automation. Instead of manually installing nginx after the VM starts, cloud-init handles installation and configuration. The cloud-init file becomes part of the infrastructure code, defining what software runs and how it's configured.

Configuration files for Flask applications can be committed to Git alongside application code. Different configuration files for development and production environments document environment differences. This progression from manual configuration to versioned configuration files demonstrates Configuration as Code.

### Week 3-4: Documentation and Testing

Project documentation written in Markdown and stored in the repository follows Documentation as Code principles. Setup instructions, architecture decisions, and troubleshooting guides live alongside the code they describe. When deployment procedures change, the documentation updates in the same commit.

Simple validation scripts can check that infrastructure meets requirements. A script might verify that the VM has the correct size, runs in the expected region, or has specific network security group rules. These validation scripts represent basic Policy as Code.

### Implementing GitOps Principles

Full GitOps requires tooling like Kubernetes and controllers like Flux or ArgoCD, which exceeds the scope of introductory projects. However, GitOps principles can guide simpler implementations.

Using Git as the single source for infrastructure definitions, even without automated reconciliation, builds GitOps thinking. Infrastructure changes happen by updating files in Git and running deployment scripts, not by making ad-hoc modifications through the portal. This discipline creates the audit trail and reproducibility that GitOps formalizes.

A deployment script that checks Git for the latest infrastructure definitions before applying changes moves toward GitOps. The script ensures production matches what Git defines, catching drift where production state diverges from the repository.

## Progression and Decision Points

The DevOps philosophy spectrum represents a progression, not a checklist. Organizations and projects move along this spectrum based on need, team size, and operational maturity.

Small projects with one or two developers may not need full GitOps automation. Infrastructure as Code through Bash scripts and cloud-init provides significant benefits without operational complexity. As projects scale—more developers, more environments, more frequent deployments—investing in GitOps tooling pays dividends through reduced manual effort and increased reliability.

The key insight is that infrastructure, configuration, documentation, policies, and operational processes can all be treated as code. This treatment enables version control, code review, automated testing, and all the other practices that improve software quality. The extent to which a project codifies these elements depends on its specific requirements and constraints.

For student projects, the goal is understanding the spectrum and practicing the fundamental techniques. Creating infrastructure through scripts instead of portals. Version controlling configuration instead of storing it in databases. Writing documentation in Markdown alongside code instead of in separate wikis. These practices build the foundation for more sophisticated approaches as projects grow in complexity.

## Summary

The "as code" paradigm transforms infrastructure and operations from manual processes into version-controlled artifacts that support engineering practices like code review, testing, and continuous integration. Infrastructure as Code provides the foundation by defining infrastructure in text files rather than through manual actions. Configuration as Code, Documentation as Code, and Policy as Code extend this pattern to other operational aspects. GitOps represents the culmination, where Git becomes the single source of truth for system state and automated controllers maintain production systems in sync with repository definitions.

Student projects encounter this spectrum gradually, progressing from manual portal operations to scripted provisioning, automated configuration, and version-controlled documentation. Each step builds understanding of how treating operational concerns as code improves reproducibility, auditability, and team collaboration. The specific point on the spectrum depends on project requirements, but the underlying philosophy—that infrastructure and operations benefit from the same engineering practices as application development—remains constant.
