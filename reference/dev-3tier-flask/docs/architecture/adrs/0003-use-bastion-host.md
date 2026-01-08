# 3. Use Bastion Host for SSH Access

Date: 2025-12-15

## Status

Superseded by [ADR-0004](0004-use-direct-ssh.md)

## Context

We need secure administrative access to internal VMs without exposing them directly to the internet.

Options considered:
1. Direct SSH access to all VMs (public IPs)
2. VPN gateway
3. Azure Bastion service (PaaS)
4. Self-managed bastion host (jump server)

## Decision

We will use a self-managed bastion host (Ubuntu VM) as an SSH jump server.

## Consequences

**Positive:**
- Only one public SSH endpoint exposed
- Internal VMs have no public IPs (reduced attack surface)
- Full control over bastion configuration
- Consistent with IaaS approach

**Negative:**
- Additional VM to maintain
- Single point of failure for admin access
- Requires SSH key management

## Superseded

This decision was superseded by ADR-0004 which adopts direct SSH access for the simplified learning environment. The bastion host pattern remains valid for production deployments.
