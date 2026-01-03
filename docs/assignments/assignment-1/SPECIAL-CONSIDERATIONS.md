# Assignment 1 - Special Considerations

This document describes exceptions and adjustments made during the course due to technical circumstances.

## Excluded Requirements

The following components were **not required to implement in practice** due to Azure resource limitations for new accounts during the course period.

**Root cause:** Azure restricts the number of virtual machines that new accounts can provision. Students could not deploy enough VMs to implement the full reference architecture.

### 1. Bastion Host

**What:** A dedicated jump server in a separate subnet for secure SSH access to internal VMs.

**Why excluded:** Requires an additional VM, exceeding Azure's quota for new accounts.

**Evaluation approach:**
- **Not required:** Working bastion host implementation
- **Valued:** Theoretical understanding and mention of bastion host as a security best practice
- **VG consideration:** Students who discuss why a bastion host would improve security demonstrate deeper understanding

### 2. HTTPS / SSL Certificates

**What:** TLS encryption for the web application using SSL certificates.

**Why excluded:** Proper HTTPS setup requires a reverse proxy VM (nginx) separate from the application server, which exceeded available VM quota.

**Evaluation approach:**
- **Not required:** Working HTTPS on deployment
- **Valued:** Theoretical understanding that production systems require HTTPS
- **VG consideration:** Students who discuss HTTPS as a future improvement or security requirement demonstrate awareness

## Evaluation Guidance

When evaluating student reports:

1. **Do not penalize** students for missing bastion host or HTTPS implementation
2. **Give credit** when students mention these as theoretical requirements or future improvements
3. **Consider for VG** when students demonstrate understanding of *why* these components matter for security, even without implementation

## Example Good Responses

**Acceptable (meets requirements):**
> "SSH access is configured with key-based authentication to the application server."

**Better (shows awareness):**
> "In a production environment, a bastion host would provide an additional security layer for SSH access. Due to time constraints, direct SSH access is currently configured."

**Best (demonstrates understanding):**
> "The current architecture allows direct SSH to the app server. A more secure design would route all SSH traffic through a bastion host in a dedicated management subnet, limiting the attack surface. This is identified as a priority for the next iteration."
