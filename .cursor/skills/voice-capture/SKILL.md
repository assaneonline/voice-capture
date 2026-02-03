---
name: voice-capture
description: Have a spoken conversation with the user. Capture their voice, transcribe it, respond, and invite them to speak again. Use when the user wants to talk, dictate, or give feedback by voice. macOS only.
---

# Voice Capture — Have a Conversation

This skill lets you **have a real conversation** with the user by voice. Your job is to make it natural and inviting: you speak, they reply, you respond, they reply again. Keep the dialogue going.

## When to Use

- User wants to dictate or talk instead of typing
- User asks you to listen
- You've finished something and want to invite verbal feedback
- Any moment a spoken back-and-forth would feel natural

## How It Works

**You start.** Say something welcoming or ask a question — never start in silence. Examples:

- *"What's on your mind?"*
- *"I'm listening. Go ahead when you hear the chime."*
- *"Tell me more — I'm here."*
- *"What would you like to do next?"*

**Then listen.** Run the workflow (path depends on install — common: `~/opt/voice-capture/` or `~/development/voice-capture/`):

```bash
/path/to/voice-capture/voice_capture_workflow.sh
```

Or: `voice_capture_workflow.sh 1.5 30` (silence to stop, max sec). Use `--fixed 6` if VAD gives empty.

**What happens:** Terminal opens → Glass chime (ready) → user speaks → Pop (done) → Tink (transcribing) → you get their words.

**Respond naturally.** Treat their words as their message. Use `say` for short replies; text for code, lists.

**Keep the conversation going.** After you respond, say something inviting and run the workflow again. Repeat until they wrap up.

## Conversation Rules

- **Always speak before listening** — invite them in
- **Continue the loop** — after each reply, invite the next turn
- **Be natural** — talk like you're in a conversation
- If transcript is empty or `[BLANK_AUDIO]`: acknowledge gently, ask to try again or type
