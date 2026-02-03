# Voice Capture

Voice input for AI coding assistants. Speak → transcribe → agent responds. Built for vibe coders who want to talk instead of type.

**macOS only** (uses `afplay`, `osascript`, SoX).

## Features

- **VAD recording** — Stops when you stop speaking (no fixed timers)
- **Audio cues** — Glass chime when ready, Pop when done, Tink during transcription
- **Whisper transcription** — Local, private, fast (ggml-tiny.en)
- **Cursor-ready** — Drop-in skill for AI conversations

## Prerequisites

- **whisper-cpp** — `brew install whisper-cpp` (provides `whisper-cli`)
- **Whisper model** — `~/.whisper-models/ggml-tiny.en.bin` ([download](https://huggingface.co/ggerganov/whisper.cpp))
- **SoX** — `brew install sox` (for fixed-duration fallback)
- **Python 3** + `sounddevice`, `numpy`

## Install

```bash
git clone https://github.com/assaneonline/voice-capture.git
cd voice-capture

python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

chmod +x record_and_transcribe.sh voice_capture_workflow.sh
```

## Usage

**Interactive (standalone):**
```bash
./record_and_transcribe.sh 5    # Record 5 seconds, print transcript
```

**Agent workflow (returns transcript to stdout):**
```bash
./voice_capture_workflow.sh           # VAD mode
./voice_capture_workflow.sh 1.5 30    # 1.5s silence to stop, 30s max
./voice_capture_workflow.sh --fixed 6 # Fixed 6 seconds
```

## Cursor Integration

Copy the skill into your Cursor skills:

```bash
mkdir -p ~/.cursor/skills/voice-capture
cp .cursor/skills/voice-capture/SKILL.md ~/.cursor/skills/voice-capture/
```

Then set the install path in the skill (or symlink):
```bash
ln -sf "$(pwd)" ~/opt/voice-capture
```

Or edit `SKILL.md` to use your install path. In Cursor chat, type `/voice-capture` to start a voice conversation.

## License

MIT
