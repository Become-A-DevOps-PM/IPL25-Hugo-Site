# Disable AirPlay Receiver on macOS to Reclaim Port 5000

Flask uses port 5000 by default. Since macOS Monterey (12.0), Apple's AirPlay Receiver service occupies this port, causing a conflict when starting Flask.

## Symptoms

When running `flask run`, you see:

```
Address already in use
Port 5000 is in use by another program.
```

## Solution

### Option 1: Disable AirPlay Receiver (Recommended)

1. Open **System Settings**
2. Navigate to **General** → **AirDrop & Handoff**
3. Toggle **AirPlay Receiver** to **Off**

Port 5000 is now available for Flask.

### Option 2: Use a Different Port

If you need AirPlay Receiver, run Flask on another port:

```bash
flask run --port 5001
```

## Verify

Check if port 5000 is free:

```bash
lsof -i :5000
```

No output means the port is available.
