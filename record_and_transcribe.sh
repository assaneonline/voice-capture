#!/bin/bash
# Record your voice, then transcribe with Whisper
# Usage: ./record_and_transcribe.sh [duration] [transcript_output_file] [silence_stop] [max_duration]
#   - duration: seconds to record (default 5)
#   - transcript_output_file: optional; if set, skip countdown and write transcript to this file
#   - silence_stop: optional; if set, use VAD/silence mode - stop after N sec of silence (default 1.5)
#   - max_duration: optional; max recording seconds in silence mode (default 60)

DURATION=${1:-5}
TRANSCRIPT_FILE="$2"
SILENCE_STOP=${3:-1.5}
MAX_DURATION=${4:-60}
MODEL="${WHISPER_MODEL:-$HOME/.whisper-models/ggml-tiny.en.bin}"
OUT="/tmp/my_speech.wav"

# VAD/silence mode: $3 (silence_stop) set when called from voice_capture_workflow
USE_SILENCE_MODE=false
if [ -n "$TRANSCRIPT_FILE" ] && [ -n "$3" ]; then
  USE_SILENCE_MODE=true
fi

if [ -z "$TRANSCRIPT_FILE" ]; then
  # Interactive mode: countdown, then record
  echo "=== Voice → Text ==="
  echo "Recording $DURATION seconds. Speak when you see 'Recording...'"
  echo ""
  for i in 3 2 1; do
    echo "$i..."
    sleep 1
  done
fi

echo "Recording... SPEAK NOW!"
echo ""

# Record
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$USE_SILENCE_MODE" = true ]; then
  PYTHON_VAD="${SCRIPT_DIR}/.venv/bin/python"
  [ -x "$PYTHON_VAD" ] || PYTHON_VAD="python3"
  "$PYTHON_VAD" "$SCRIPT_DIR/record_with_vad.py" -o "$OUT" -s "$SILENCE_STOP" -m "$MAX_DURATION" -q 2>/dev/null || \
  rec -r 16000 -c 1 "$OUT" trim 0 "$MAX_DURATION" 2>/dev/null
else
  rec -r 16000 -c 1 "$OUT" trim 0 $DURATION 2>/dev/null
fi

echo ""
echo "Transcribing..."

(
  while true; do
    afplay /System/Library/Sounds/Tink.aiff 2>/dev/null
    sleep 2
  done
) &
WAIT_SOUND_PID=$!

if [ -n "$TRANSCRIPT_FILE" ]; then
  whisper-cli -m "$MODEL" -np "$OUT" 2>/dev/null | sed 's/^\[[^]]*\]\s*//' | tr '\n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > "$TRANSCRIPT_FILE"
  echo "Done. Transcript written to $TRANSCRIPT_FILE"
else
  whisper-cli -m "$MODEL" -np "$OUT" 2>/dev/null
  echo ""
  echo "Done! Audio saved to $OUT"
fi

kill $WAIT_SOUND_PID 2>/dev/null
