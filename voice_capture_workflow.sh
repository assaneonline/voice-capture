#!/bin/bash
# Orchestrator for agent-driven voice capture: opens Terminal, records, waits, returns transcript.
# Usage: ./voice_capture_workflow.sh [silence_stop_sec] [max_duration_sec]
#        ./voice_capture_workflow.sh --fixed [duration_sec]

TRANSCRIPT_FILE="${CURSOR_VOICE_FILE:-/tmp/cursor_voice.txt}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$1" = "--fixed" ]; then
  FIXED_DURATION=${2:-6}
  RECORD_CMD="./record_and_transcribe.sh $FIXED_DURATION '$TRANSCRIPT_FILE'"
  POLL_MAX=30
else
  SILENCE_STOP=${1:-1.5}
  MAX_DURATION=${2:-30}
  RECORD_CMD="./record_and_transcribe.sh 0 '$TRANSCRIPT_FILE' $SILENCE_STOP $MAX_DURATION"
  POLL_MAX=45
fi

: > "$TRANSCRIPT_FILE"

osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR' && $RECORD_CMD\""

for i in $(seq 1 $POLL_MAX); do
  [ -s "$TRANSCRIPT_FILE" ] && break
  sleep 2
done

cat "$TRANSCRIPT_FILE"
