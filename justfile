ecr := "918821718107.dkr.ecr.eu-west-1.amazonaws.com/docker-minecraft-gregtech-new-horizons"

build tag:
    #!/usr/bin/env bash
    set -euo pipefail
    podman build --platform linux/amd64 --tag {{ecr}}:{{tag}}-amd64 .
    podman build --platform linux/arm64 --tag {{ecr}}:{{tag}}-arm64 .
    podman manifest create {{ecr}}:{{tag}} {{ecr}}:{{tag}}-amd64 {{ecr}}:{{tag}}-arm64
    podman manifest push {{ecr}}:{{tag}} docker://{{ecr}}:{{tag}}

login:
    aws ecr get-login-password --region eu-west-1 --profile alisonRW-script | podman login --username AWS --password-stdin 918821718107.dkr.ecr.eu-west-1.amazonaws.com

alias b := build
alias l := login
