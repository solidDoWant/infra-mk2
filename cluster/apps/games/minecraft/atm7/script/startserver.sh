#!/bin/sh
set -eu
DEFAULT_FORGE_VERSION=40.1.74
if [ -z ${FORGE_VERSION+x} ]; then
    if [ -f "forge_version.txt" ]; then
        FORGE_VERSION=$(cat "forge_version.txt")
    else
        FORGE_VERSION=$DEFAULT_FORGE_VERSION
    fi
fi

# To use a specific Java runtime, set an environment variable named JAVA_COMMAND to the full path of `java`.
DEFAULT_JAVA_COMMAND=java
JAVA_COMMAND=${JAVA_COMMAND:-$DEFAULT_JAVA_COMMAND}

INSTALLER="forge-1.18.2-$FORGE_VERSION-installer.jar"
FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/forge-1.18.2-$FORGE_VERSION-installer.jar"

if ! command -v "$JAVA_COMMAND" >/dev/null 2>&1; then
    echo "Minecraft 1.18 requires Java 17 - Java not found"
    pause
    exit 1
fi

JAVA_VERSION=$("$JAVA_COMMAND" -fullversion 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ ! "$JAVA_VERSION" -ge 17 ]; then
    echo "Minecraft 1.18 requires Java 17 - found Java $JAVA_VERSION"
    pause
    exit 1
fi

cd "$(dirname "$0")"
CHECKFILE_NAME="libraries/$FORGE_VERSION-success.txt"
if [ ! -f "$CHECKFILE_NAME" ]; then
    echo "Forge not installed, installing now."
    if [ -f "$INSTALLER" ]; then
        echo "Removing old installer"
        rm "$INSTALLER"
    fi

    if command -v wget >/dev/null 2>&1; then
        echo "DEBUG: (wget) Downloading $FORGE_URL"
        wget -O "$INSTALLER" "$FORGE_URL"
    else
        if command -v curl >/dev/null 2>&1; then
            echo "DEBUG: (curl) Downloading $FORGE_URL"
            curl -o "$INSTALLER" -L "$FORGE_URL"
        else
            echo "Neither wget or curl were found on your system. Please install one and try again"
            exit 1
        fi
    fi

    if [ -d "libraries" ]; then
        echo "Removing potentially old libraries"
        rm rf "libraries"
    fi

    echo "Running Forge installer."
    "$JAVA_COMMAND" -jar "$INSTALLER" -installServer

    echo "success" > "$CHECKFILE_NAME"
fi

if [ ! -e server.properties ]; then
    echo -e "allow-flight=true" > server.properties
fi

"$JAVA_COMMAND" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/unix_args.txt nogui
