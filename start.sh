#!/bin/bash

if [ ! -f "./tor/tor" ]; then
    echo "Downloading Tor bundle..."
    curl -sSL "https://archive.torproject.org/tor-package-archive/torbrowser/13.5.3/tor-expert-bundle-linux-x86_64-13.5.3.tar.gz" -o tor.tar.gz
    tar -xzf tor.tar.gz
    chmod +x ./tor/tor
fi

export LD_LIBRARY_PATH="./tor:$LD_LIBRARY_PATH"

echo "Starting Tor in Ultra-Low Resource mode..."
# Process ප්‍රමුඛතාවය අඩුම මට්ටමට (nice 19) දමා ධාවනය කිරීම
exec nice -n 19 ./tor/tor -f torrc