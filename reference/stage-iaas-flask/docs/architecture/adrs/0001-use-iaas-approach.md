# 1. Use Pure IaaS Approach

Date: 2025-12-15

## Status

Accepted

## Context

We need to choose an infrastructure approach for hosting the webinar registration website on Azure.

Options considered:
1. Pure IaaS (Virtual Machines)
2. PaaS (App Service, Container Apps)
3. Serverless (Functions)

## Decision

We will use a pure IaaS approach with self-managed Ubuntu VMs for compute.

## Consequences

**Positive:**
- Full control over the environment
- Traditional Linux administration skills applicable
- No vendor lock-in for compute layer
- Educational value for understanding infrastructure fundamentals

**Negative:**
- More operational overhead (patching, monitoring)
- No built-in auto-scaling
- Requires more infrastructure knowledge

**Exception:**
- PostgreSQL will use Azure Flexible Server (PaaS) for practical reasons (managed backups, HA)
