# Reference Implementations

This directory contains reference implementations demonstrating different architecture patterns and complexity levels.

## Stage Naming Convention

Reference implementations follow a **stage-based naming convention** for progressive architecture complexity:

| Stage | Description | Key Characteristics |
|-------|-------------|---------------------|
| `stage-iaas-{app}` | **Pure IaaS baseline** | VMs only, self-managed networking, no managed services |
| `stage-hybrid-{app}` | IaaS + managed secrets | Adds Azure Key Vault for secrets management |
| `stage-managed-{app}` | Managed networking | Adds Azure Bastion, Application Gateway |
| `stage-scalable-{app}` | Auto-scaling | Adds VM Scale Sets, load balancing |
| `stage-paas-{app}` | Full PaaS | App Service, fully managed database |

The `{app}` suffix indicates the application type (e.g., `flask`, `django`, `node`), allowing the same architecture patterns to be demonstrated with different technology stacks.

### Progression Philosophy

Each stage builds upon the previous one by replacing self-managed components with Azure managed services:

```
stage-iaas       → stage-hybrid      → stage-managed     → stage-scalable   → stage-paas
(VMs only)         (+Key Vault)        (+Azure Bastion)    (+Scale Sets)      (App Service)
                                       (+App Gateway)      (+Load Balancer)
```

Depending on the course and audience, different stages may serve as the capstone project. The stage names describe architecture complexity, not course progression.

## Current Implementations

| Directory | Stage | Description |
|-----------|-------|-------------|
| `stage-iaas-flask/` | IaaS | Pure IaaS Flask deployment with Bicep |
| `stage-ultimate/` | Hybrid | Flask with Key Vault (Azure CLI based) |
| `https-self-signed/` | Tutorial | Single-VM HTTPS setup tutorial |

## Standalone Tutorials

Some reference implementations are standalone tutorials rather than staged architectures:

- **`https-self-signed/`** - Single-VM nginx with self-signed SSL certificate
