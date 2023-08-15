#!/bin/bash

function download_file() {
    URL="$1"
    OUTPUT="$2"

    wget -q "$URL" "$OUTPUT"
}

# Source mod plugins
PLUGIN_DIR="/data/serverfiles/insurgency/addons/sourcemod/plugins/"
download_file "https://www.sourcemod.net/vbcompiler.php?file_id=143100" "$PLUGIN_DIR/MyCompass.smx"
download_file "https://www.sourcemod.net/vbcompiler.php?file_id=143044" "$PLUGIN_DIR/SpecDetails.smx"
download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/ammocheck.smx" "$PLUGIN_DIR/AmmoStatus.smx"
download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/botcount.smx" "$PLUGIN_DIR/BotCount.smx"
download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/restrictedareas.smx" "$PLUGIN_DIR/RestrictedAreasRemoval.smx"
download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/respawn.smx" "$PLUGIN_DIR/Respawn.smx"

# Source mod config
{
    echo '"STEAM_1:0:36668633" "99:z"'
} > /data/serverfiles/insurgency/addons/sourcemod/configs/admins_simple.ini

{
    echo ""
} > /data/serverfiles/insurgency/cfg/sourcemod/
