#!/bin/bash

# Source mod plugins
PLUGIN_DIR="/data/serverfiles/insurgency/addons/sourcemod/plugins/"
wget "https://www.sourcemod.net/vbcompiler.php?file_id=143100" "$PLUGIN_DIR/MyCompass.smx"
wget "https://www.sourcemod.net/vbcompiler.php?file_id=143044" "$PLUGIN_DIR/SpecDetails.smx"
wget "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/ammocheck.smx" "$PLUGIN_DIR/AmmoStatus.smx"
wget "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/botcount.smx" "$PLUGIN_DIR/BotCount.smx"
wget "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/restrictedareas.smx" "$PLUGIN_DIR/RestrictedAreasRemoval.smx"
wget "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/respawn.smx" "$PLUGIN_DIR/Respawn.smx"

# Source mod config
{
    echo '"76561198033602994" "99:z"'
} > /data/serverfiles/insurgency/addons/sourcemod/configs/admins_simple.ini
