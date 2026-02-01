# Reference Implementations

This directory contains reference Flask applications at different architecture complexity levels. Each implementation has its own CLAUDE.md with detailed documentation.

## Implementation Comparison

| Implementation | Architecture | VMs | Database | SSH Access | Cost/mo | Purpose |
|---------------|-------------|-----|----------|-----------|---------|---------|
| `hello-flask/` | Minimal | 0 | None | N/A | Free | Flask hello-world |
| `starter-flask/` | Container Apps | 0 | Azure SQL (optional) | N/A | ~$15-20 | Container deployment |
| `news-flask/` | Single VM | 1 | SQLite | Direct | ~$10 | Flask patterns |
| `dev-3tier-flask/` | Single VM | 1 | PostgreSQL (PaaS) | Direct | ~$20 | App development |
| `https-self-signed/` | Single VM | 1 | None | Direct | ~$10 | SSL tutorial |
| `stage-iaas-flask/` | Multi-VM IaaS | 3 | PostgreSQL (PaaS) | Via bastion | ~$35 | IaaS with Bicep |
| `stage-ultimate/` | Multi-VM Hybrid | 3 | PostgreSQL (PaaS) | Via bastion | ~$40-50 | Defense in depth |

## When to Use Which

- **Learning Flask basics** -> `hello-flask/` or `news-flask/`
- **Learning Container Apps** -> `starter-flask/`
- **Learning VM deployment + database** -> `dev-3tier-flask/`
- **Learning SSL/HTTPS** -> `https-self-signed/`
- **Learning IaC with Bicep** -> `stage-iaas-flask/`
- **Learning network security and production patterns** -> `stage-ultimate/`

## Stage Naming Convention

Implementations prefixed with `stage-` follow progressive architecture complexity:

```
stage-iaas       -> stage-hybrid      -> stage-managed     -> stage-scalable   -> stage-paas
(VMs only)         (+Key Vault)        (+Azure Bastion)    (+Scale Sets)      (App Service)
                                       (+App Gateway)      (+Load Balancer)
```

The `{app}` suffix indicates the application type. See `README.md` for full naming details.

## Per-Implementation Documentation

Each subdirectory with a CLAUDE.md contains its own architecture, quick-start, and directory structure. Refer to those for implementation-specific details:

- `stage-ultimate/CLAUDE.md` - 3-VM bastion architecture with Key Vault
- `stage-iaas-flask/CLAUDE.md` - 3-VM IaaS with Bicep templates
- `dev-3tier-flask/CLAUDE.md` - Single-VM Flask with blueprints (118 tests)
- `starter-flask/CLAUDE.md` - Container Apps with graceful degradation
- `news-flask/CLAUDE.md` - Flask patterns and SQLite
