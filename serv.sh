#!/usr/bin/env bash
# mistral orca
set -euo pipefail && cd "$(dirname "${BASH_SOURCE[0]}")"

# if you use models in multiple places, imo it makes sense to symlink the models folder from somewhere else
MISTRAL_GGUF="mistral-7b-instruct-v0.1.Q5_K_S.gguf"
MODELS_DIR="models"
MODEL=${1-"$MODELS_DIR/$MISTRAL_GGUF"}
HUGGING_FACE_URL="https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF/resolve/main/mistral-7b-openorca.Q5_0.gguf"

if [[ ! -f "$MODEL" ]]; then
  echo "Model doesn't exist."

  read -e -p "Do you want to download mistral-7b? It's 5GB. [Y/n] " SHOULD_DOWNLOAD
  if [[ "$SHOULD_DOWNLOAD" == [Yy]* ]]; then 
    echo "OK! Downloading"
    mkdir -p $MODELS_DIR
    pushd $MODELS_DIR
    curl --compressed --remote-name --progress-bar -L "$HUGGING_FACE_URL" || exit 1
    popd
    MODEL="$MODELS_DIR/$MISTRAL_GGUF"
  else
    echo "Ok, bye!" 
    exit 1
  fi
fi


rlwrap --always-readline -N\
  llama-server -m $MODEL \
  --mlock \
  -c 4096 \
  --n-gpu-layers 1 \
  --threads 8
  "${@:2}"
