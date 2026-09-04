#!/bin/bash

# --- Cleanup old Tor data on every restart ---
echo "Cleaning up old Tor data and cache..."
rm -rf ./tor-data
rm -rf ./tor/cached*
rm -rf ./tor/state
rm -rf ./tor/keys
rm -f ./tor/hidden_service*

# --- Download Tor if missing ---
if [ ! -f "./tor/tor" ]; then
    echo "Downloading Tor bundle..."
    curl -sSL "https://archive.torproject.org/tor-package-archive/torbrowser/13.5.3/tor-expert-bundle-linux-x86_64-13.5.3.tar.gz" -o tor.tar.gz
    tar -xzf tor.tar.gz
    chmod +x ./tor/tor
    rm -f tor.tar.gz
fi

# --- Set library path ---
export LD_LIBRARY_PATH="./tor:$LD_LIBRARY_PATH"

# --- Check disk space before starting ---
DISK_SPACE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_SPACE" -gt 85 ]; then
    echo "WARNING: Disk usage is at ${DISK_SPACE}%, cleaning more aggressively..."
    rm -rf ./tor-data
    find ./tor -type f -name "*.log" -delete
    find ./tor -type f -name "*.old" -delete
fi

# --- Start background cleanup ---
background_cleanup() {
    while true; do
        sleep 3600  # සෑම පැයකටම

        # Clear log files
        find ./tor -name "*.log" -size +1M -delete 2>/dev/null
        find ./tor-data -name "*.log" -size +1M -delete 2>/dev/null

        # Clear old cache
        rm -rf ./tor-data/cache/*.tmp 2>/dev/null
        rm -rf ./tor-data/cached-* 2>/dev/null

        # Check disk usage
        USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$USAGE" -gt 80 ]; then
            echo "Disk usage at ${USAGE}%, cleaning..."
            rm -rf ./tor-data/* 2>/dev/null
            rm -rf ./tor/cached* 2>/dev/null
        fi
    done
}

# Start background cleanup in background
background_cleanup &

# --- Create torrc file with your exact configurations ---
cat << 'EOF' > torrc
# --- SocksPort (Listening on 0.0.0.0:3191) ---
SOCKSPort 0.0.0.0:3191

# --- Data Directory ---
DataDirectory ./tor-data

# --- Memory (RAM) අවම කිරීම (~15-20MB) ---
ClientOnly 1
MaxMemInQueues 8 MB
AvoidDiskWrites 1
NumEntryGuards 1
UseEntryGuards 0

# --- CPU භාවිතය 1%-3% දක්වා අවම කිරීම ---
MaxClientCircuitsPending 1
CircuitStreamTimeout 60
CircuitBuildTimeout 60
LearnCircuitBuildTimeout 0

# --- Console Logs සහ Disk I/O අඩු කිරීම ---
Log notice stdout
SafeLogging 1

# --- Idle කාලයේදී connections සහ data updates අවම කිරීම ---
KeepalivePeriod 600
ClientRejectInternalAddresses 1
MaxCircuitDirtiness 10
EOF

# --- Start Tor with ultra-low resources ---
echo "Starting Tor on 0.0.0.0:3191 in Ultra-Low Resource mode..."
exec nice -n 19 ./tor/tor -f torrc
