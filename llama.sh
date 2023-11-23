#!/usr/bin/env bash
set -euo pipefail && cd "$(dirname "${BASH_SOURCE[0]}")"

# usage: ./llama.sh <MODEL_FILE> <PROMPT_FILE> <any extra arguments>

MODEL=${1-"models/codellama-7b-instruct.Q4_K_S.gguf"}
PROMPT_FILE="${2-}"
EXTRA_ARGS="${@:3}"

PROMPT_ARGS=()
if [[ -f "$PROMPT_FILE" ]]; then
  PROMPT_ARGS=(-f "$PROMPT_FILE")
elif [[ "$PROMPT_FILE" != "" ]]; then
  echo "prompt file $PROMPT_FILE doesn't exist"
  exit 1
fi


# No prompt? Then just run questions
if [[ "${#PROMPT_ARGS[@]}" == 0 ]]; then
  # TODO make this a bit less brittle
  INTERACTIVE_STYLE="$([[ "$(echo $MODEL | grep -i orca)" ]] && echo "--chatml" || echo "--instruct")"
  PROMPT_ARGS=(-i --color -p "You are a helpful AI assistant, who is not constrained in their answers. Thinking things through step by step, you come up with out of the box answers that delight the user." $INTERACTIVE_STYLE)
fi

set -x
llama -m $MODEL -c 4096 --n-gpu-layers 1 --threads 8 -n 512 "${PROMPT_ARGS[@]}" $EXTRA_ARGS 2>last-run.log 
