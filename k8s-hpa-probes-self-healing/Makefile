.PHONY: cluster deploy load unload watch chaos-container chaos-pod chaos-node uncordon rollback destroy
cluster:          ; ./scripts/00-cluster.sh
deploy:           ; ./scripts/01-deploy.sh
load:             ; ./scripts/02-load.sh on
unload:           ; ./scripts/02-load.sh off
watch:            ; while true; do clear; kubectl -n tbx get hpa,po; sleep 2; done
chaos-container:  ; ./scripts/03-chaos.sh container
chaos-pod:        ; ./scripts/03-chaos.sh pod
chaos-node:       ; ./scripts/03-chaos.sh node
uncordon:         ; ./scripts/03-chaos.sh uncordon
rollback:         ; kubectl -n tbx rollout undo deploy/tbx-api && kubectl -n tbx rollout status deploy/tbx-api
destroy:          ; ./scripts/99-destroy.sh
