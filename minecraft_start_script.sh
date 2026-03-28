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

# Persist server admin files on EFS by symlinking them into the world directory
# The world directory is mounted on EFS, so files there survive restarts
for f in banned-ips.json banned-players.json ops.json whitelist.json usercache.json; do
    if [ -f "world/${f}" ] && [ ! -L "${f}" ]; then
        # EFS has a previous copy — use it
        rm -f "${f}"
        ln -s "world/${f}" "${f}"
    elif [ ! -L "${f}" ]; then
        # First run or no existing data — move the default and symlink
        mv "${f}" "world/${f}" 2>/dev/null || touch "world/${f}"
        ln -s "world/${f}" "${f}"
    fi
done

rconc server add mc 127.0.0.1:25575 "${RCONC_SERVER_PASSWORD}"

# shellcheck disable=2086
java $JAVA_ARGS @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui &

echo "$!" >/tmp/minecraft.pid

while kill -0 "$(cat /tmp/minecraft.pid)" &>/dev/null; do
    sleep 61440
done
