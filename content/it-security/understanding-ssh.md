+++
title = "Understanding SSH"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "A beginner's guide to SSH authentication and key management"
weight = 1
+++

SSH (Secure Shell) is a protocol for securely connecting to remote computers over a network. When managing servers, SSH provides encrypted communication and strong authentication, making it the standard method for remote server administration.

To use SSH, you type commands in a terminal window. Your computer needs an SSH client (included by default on macOS, Linux, and modern Windows), and the remote machine needs an SSH server running. Servers typically have this installed, but regular desktop computers usually do not.

This document explains how SSH key-based authentication works, where the relevant files are stored, and what happens when you connect to a server.

## Why Key-Based Authentication?

Password authentication has limitations:

- Passwords can be guessed or brute-forced
- Typing passwords for every connection is tedious
- Automated scripts cannot easily use passwords
- Passwords must be stored or transmitted somehow

Key-based authentication solves these problems by using cryptographic key pairs instead of passwords.

## Public and Private Keys

SSH uses asymmetric cryptography, which means two different but mathematically related keys work together:

**Private key** - Think of this as a physical key. It stays with you and should never be shared with anyone. This key proves your identity.

**Public key** - Think of this as a lock. You can install copies of this lock on any door (server) you want to access. Anyone can see the lock, but only your private key can open it.

This is the essential concept: the private key is the key, and the public key is the lock. You can place the same lock on many doors, and your single key opens all of them.

Despite the cryptographic terminology, both keys are simply text files. The public key is a single line:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDfT3L2AOoX3Gp1Mz... user@computer
```

The private key is a longer text block with clear markers:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
c2gtZWQyNTUxOQAAACBw3093...
...more lines of encoded data...
-----END OPENSSH PRIVATE KEY-----
```

You can open these files in any text editor. There is nothing magical about them beyond the long strings of characters that represent the cryptographic data.

### Key Properties

- The private key can "unlock" anything secured with the matching public key
- Knowing the public key does not help you figure out the private key
- If someone copies your private key, they can impersonate you
- If you lose your private key, you lose access (there is no recovery)

## Where Keys Live on Your System

SSH keys and configuration files are stored in a hidden directory called `.ssh` in your home folder.

### On Your Local Computer (the Client)

```text
~/.ssh/
├── id_rsa               # Your private key (keep secret)
├── id_rsa.pub           # Your public key (safe to share)
└── known_hosts          # Fingerprints of servers you have connected to
```

The filenames may vary depending on the key type:

- `id_rsa` / `id_rsa.pub` - RSA keys (still the default in many tools)
- `id_ed25519` / `id_ed25519.pub` - Ed25519 keys (modern alternative)

The `known_hosts` file stores the identity of servers you have connected to before. This prevents man-in-the-middle attacks by warning you if a server's identity changes. This file is the reason you are asked "Are you sure you want to continue connecting (yes/no)?" the first time you connect to a new server. When you answer "yes", the server's identity is saved to `known_hosts`, and you will not be asked again for that server.

### On the Remote Server

```text
~/.ssh/
└── authorized_keys      # Public keys allowed to connect as this user
```

The `authorized_keys` file contains a list of public keys. If your public key is in this file, and you have the matching private key, you can connect.

Each line in `authorized_keys` is one public key. A server can have many keys listed, allowing multiple people or machines to connect. For example:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... alice@laptop
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... alice@work-pc
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... bob@desktop
```

In this example, three keys are authorized: Alice can connect from two different computers, and Bob can connect from one.

## The Connection Process

When you run `ssh user@server`, the following sequence occurs:

```mermaid
sequenceDiagram
    participant C as Your Computer
    participant S as Remote Server

    C->>S: 1. Request connection
    S->>C: 2. Server identifies itself
    C->>C: 3. Verify server identity (known_hosts)
    S->>C: 4. Send challenge
    C->>C: 5. Sign challenge with private key
    C->>S: 6. Return signed response
    S->>S: 7. Verify signature using public key from authorized_keys
    S->>C: 8. Grant access
```

### Step by Step

1. **Connection request** - Your computer contacts the server on port 22 (the default SSH port)

2. **Server identification** - The server sends its host key, a unique identifier for that server

3. **Verify server identity** - Your computer checks if this server's key matches what is stored in `known_hosts`. If this is your first connection, you will see a prompt asking if you trust this server

4. **Challenge** - The server creates a random challenge and sends it to your computer

5. **Sign with private key** - Your computer uses your private key to create a cryptographic signature of the challenge. Only your private key can create this specific signature

6. **Return signature** - The signed response is sent back to the server

7. **Verify signature** - The server uses the public key from `authorized_keys` to verify that the signature is valid. This proves you possess the matching private key without ever transmitting it

8. **Access granted** - The encrypted session begins

By default, the SSH client automatically uses your key from `~/.ssh/` (such as `id_rsa`). If you have multiple keys or store a key elsewhere, you can specify which one to use with the `-i` flag:

```bash
ssh -i /path/to/my-key user@server
```

## Generating and Installing Keys

### Creating a Key Pair

Use `ssh-keygen` to create a new key pair on your local computer:

```bash
ssh-keygen
```

This creates two files:

- `~/.ssh/id_rsa` (private key)
- `~/.ssh/id_rsa.pub` (public key)

By default, `ssh-keygen` creates RSA keys. You can also create Ed25519 keys with `ssh-keygen -t ed25519`, which are more modern but less universally supported by older tools.

You will be asked for a location (press Enter for the default) and optionally a passphrase. For this course, press Enter to skip the passphrase as well. A passphrase adds extra protection if someone steals your private key file, but for learning purposes and typical development work, leaving it empty is common practice.

### Installing Your Public Key on a Server

The public key must be added to the server's `authorized_keys` file. There are several ways to do this:

#### Method 1: During VM creation (Azure)

When creating a virtual machine in Azure, the public key is placed in the correct location automatically. There are several ways to handle the key:

**A. Azure generates a new key pair (default in portal)** - Azure creates both keys for you. The public key is stored in Azure and placed on the VM. You download the private key file (`.pem`) to your computer. This is convenient but means you have a separate key for each VM.

**B. Use your existing public key (portal)** - If you already have a key pair on your computer, you can paste your public key content into the Azure portal. This lets you use the same key for multiple VMs.

**C. Use your existing public key (Azure CLI)** - When creating a VM with `az vm create`, add the `--generate-ssh-keys` flag. Despite the name, this does not always generate new keys. If you already have a key at `~/.ssh/id_rsa.pub`, it uses that existing key. It only generates a new pair if no key exists.

```bash
az vm create --name myvm --resource-group mygroup --generate-ssh-keys
```

#### Method 2: Using ssh-copy-id

If you already have password access to a server:

```bash
ssh-copy-id user@server
```

This copies your public key to the server's `authorized_keys` file.

#### Method 3: Manual copy

1. Display your public key:

   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

2. Connect to the server (using password or console access)

3. Add the key to `authorized_keys`:

   ```bash
   echo "your-public-key-content" >> ~/.ssh/authorized_keys
   ```

## Common Situations

### "Permission denied (publickey)"

This error means authentication failed. Common causes:

- Your public key is not in the server's `authorized_keys` file
- You are using the wrong username
- File permissions are incorrect (SSH is strict about permissions)
- You are using a different key than the one installed on the server

On macOS and Linux, SSH refuses to use a private key if the file permissions are too open. This is especially common when you download a new private key from Azure. You need to restrict the permissions:

```bash
chmod 400 /path/to/your-key.pem
```

This makes the file readable only by you. Windows does not have the same permission system, so this step is not required there.

### First Connection Warning

When connecting to a server for the first time, you see:

```text
The authenticity of host 'server (192.0.2.1)' can't be established.
ED25519 key fingerprint is SHA256:AbCdEf123...
Are you sure you want to continue connecting (yes/no)?
```

This is normal for first connections. SSH is asking you to verify that you are connecting to the correct server. Type `yes` to add the server to your `known_hosts` file. Future connections will not show this warning.

When writing bash scripts that connect via SSH, this interactive prompt becomes a problem. You can bypass it with the `-o StrictHostKeyChecking=no` option:

```bash
ssh -o StrictHostKeyChecking=no user@server
```

This automatically accepts the server's key without prompting. Use this only in scripts or when you trust the network, as it skips a security verification step.

### Host Key Verification Failed

If you see "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED", the server's identity differs from what is stored in `known_hosts`. This can mean:

- The server was reinstalled or replaced
- You are connecting to a different server than before
- (Rarely) Someone is intercepting your connection

If you expect the change (for example, you recreated the VM), remove the old entry from `known_hosts` and connect again:

```bash
ssh-keygen -R server-ip-address
```

Alternatively, you can delete the entire `known_hosts` file. The only consequence is that you will be asked to confirm the connection for each server again.

## Summary

| Concept | Description |
|---------|-------------|
| Private key | Your secret key, stored locally, never shared |
| Public key | The "lock" you install on servers, safe to share |
| `~/.ssh/` | Directory where SSH files are stored |
| `authorized_keys` | Server file listing which public keys can connect |
| `known_hosts` | Client file listing known server identities |
| `ssh-keygen` | Command to generate a new key pair |
| `ssh -i /path/to/key` | Connect using a specific private key |
| `chmod 400 /path/to/key` | Fix file permissions on macOS/Linux |

The fundamental concept: your private key is the key, your public key is the lock. Install the lock on any server you want to access, and your single key opens them all.
