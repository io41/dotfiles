#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v stow &> /dev/null; then
    brew install stow
fi

mkdir -p ~/.config ~/.cache ~/.local/{share,state,run,bin} || { echo "Failed to create directories"; exit 1; }

# Ensure XDG invironment variables are set
cat > ~/Library/LaunchAgents/SetupEnvironment.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.io41.tim.environment</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>
            launchctl setenv XDG_CONFIG_HOME "$HOME/.config" &&
            launchctl setenv XDG_CACHE_HOME "$HOME/.cache" &&
            launchctl setenv XDG_DATA_HOME "$HOME/.local/share" &&
            launchctl setenv XDG_STATE_HOME "$HOME/.local/state" &&
            launchctl setenv XDG_RUNTIME_DIR "$HOME/.local/run" &&
            launchctl setenv XDG_BIN_HOME "$HOME/.local/bin"
        </string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
</dict>
</plist>
EOF

chmod 644 ~/Library/LaunchAgents/SetupEnvironment.plist

stow . || { echo "Failed to stow .config files"; exit 1; }
stow -d ./~/* . --target $HOME || { echo "Failed to HOME files"; exit 1; }

echo "Logout and log back in to ensure environment variables are correctly set"
