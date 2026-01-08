# 4. Use Direct SSH Access for Simplified Learning Environment

Date: 2025-01-08

## Status

Accepted

## Context

The dev-3tier-flask project is designed as a learning environment for application development, not infrastructure security. The bastion host pattern (ADR-0003) added complexity that distracted from the primary learning objectives.

We needed to balance:
- Simplicity for learning application development patterns
- Reasonable security for a temporary learning environment
- Cost efficiency for students
- Fast deployment and troubleshooting

## Decision

We will use direct SSH access to the application server VM, eliminating the bastion host.

The simplified architecture:
- Single VM with public IP
- SSH (port 22) allowed from Internet
- fail2ban for SSH brute-force protection
- PostgreSQL with public access (firewall allows all IPs)

## Consequences

**Positive:**
- Simpler architecture focused on application development
- Faster deployment (10-15 minutes vs 20-40 minutes)
- Lower cost (~$20/month vs ~$44/month)
- Easier troubleshooting with direct access
- Clearer mental model for learners

**Negative:**
- Less secure than bastion host pattern
- Not suitable for production workloads
- SSH exposed directly to Internet (mitigated by fail2ban)
- Public PostgreSQL access is a security risk

## Security Mitigations

Despite reduced security, we maintain:
- SSH key authentication (no password auth)
- fail2ban with aggressive settings
- Self-signed SSL for HTTPS
- PostgreSQL requires SSL connections
- NSG limits inbound ports to SSH, HTTP, HTTPS only

## When to Use Bastion Pattern

The bastion host pattern (ADR-0003) should be used when:
- Deploying production workloads
- Learning infrastructure security concepts
- Multiple VMs require SSH access
- Compliance requirements mandate network segmentation

For production patterns, see `reference/stage-ultimate/`.
