#!/usr/bin/bash
function sigterm_handler() {
    echo "SIGTERM handler triggered"
    rconc mc "say Server stopping..."
    sleep 1
    rconc mc "stop"
    echo "Waiting for minecraft to stop..."
    while kill -0 "$(cat /tmp/minecraft.pid)" &>/dev/null; do
        sleep 0.1
    done
    echo "Minecraft stopped"
}
trap sigterm_handler SIGTERM

cd /srv/minecraft || exit 1

if [ -f server.properties.configmap ]; then
    cp server.properties.configmap server.properties
fi

rconc server add mc 127.0.0.1:25575 "${RCONC_SERVER_PASSWORD}"

# shellcheck disable=2086
java $JAVA_ARGS @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui &

echo "$!" >/tmp/minecraft.pid

while kill -0 "$(cat /tmp/minecraft.pid)" &>/dev/null; do
    sleep 61440
done
