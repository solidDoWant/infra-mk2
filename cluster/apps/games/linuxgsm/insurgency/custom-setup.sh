#!/bin/bash

function download_file() {
    URL="$1"
    OUTPUT="$2"

    if wget -q "$URL" -O "$OUTPUT"; then
        echo "Downloaded $OUTPUT"
        return
    fi

    echo "Failed to download $URL to $OUTPUT"
    exit 1
}

# Source mod plugins
PLUGIN_DIR="/data/serverfiles/insurgency/addons/sourcemod/plugins"
download_file "https://www.sourcemod.net/vbcompiler.php?file_id=143209" "$PLUGIN_DIR/MyCompass.smx"
download_file "https://www.sourcemod.net/vbcompiler.php?file_id=143044" "$PLUGIN_DIR/SpecDetails.smx"
download_file "https://www.sourcemod.net/vbcompiler.php?file_id=143459" "$PLUGIN_DIR/AmmoStatus.smx"
# download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/botcount.smx" "$PLUGIN_DIR/BotCount.smx"
download_file "https://github.com/jaredballou/insurgency-sourcemod/raw/master/plugins/restrictedarea.smx" "$PLUGIN_DIR/RestrictedAreaRemoval.smx"
download_file "https://github.com/rrrfffrrr/Insurgency-server-plugins/raw/master/plugins/RespawnBots2.smx" "$PLUGIN_DIR/RespawnBots.smx"
download_file "https://github.com/rrrfffrrr/Insurgency-server-plugins/raw/master/plugins/Medic.smx" "$PLUGIN_DIR/Medic.smx"

# Source mod config
{
    echo '"STEAM_1:0:36668633" "99:z"'
} > /data/serverfiles/insurgency/addons/sourcemod/configs/admins_simple.ini

{
    echo 'sm_comp_bearing "1"'
    echo 'sm_comp_enabled "1"'
    echo 'sm_comp_pos "3"'
} > /data/serverfiles/insurgency/cfg/sourcemod/plugin.MyCompass.cfg

# Setup workshop collection
echo "3020499817" > /data/serverfiles/insurgency/subscribed_file_ids.txt
