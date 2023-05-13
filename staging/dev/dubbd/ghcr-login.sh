set +o history
export CR_PAT=GHCR_PAT
export CR_USR=GHCR_USER
echo $CR_PAT | docker login ghcr.io -u $CR_USR --password-stdin
set -o history