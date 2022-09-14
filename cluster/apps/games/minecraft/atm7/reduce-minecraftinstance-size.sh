#!/bin/bash
cat minecraftinstance.json | jq '. | del(.installedAddons[].installedFile.modules) | del(.installedAddons[].latestFile) | \
    del(.installedAddons[].installedFile.sortableGameVersion) | del(.installedAddons[].installedFile.Hashes) | del(.installedAddons[].installedFile.gameVersion) | \
    del(.modpackOverrides) | del(.manifest.files[].required) | del(.baseModLoader)' > minecraftinstance2.json && mv minecraftinstance2.json minecraftinstance.json
