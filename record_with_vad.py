#!/usr/bin/env python3
"""
Record from microphone with real-time silence detection.
Starts on sound, stops after N seconds of silence. Outputs 16kHz mono WAV for Whisper.
Plays a short sound when recording stops so user knows not to continue speaking.
Requires: pip install sounddevice numpy
"""
import argparse
import subprocess
import sys
import wave

try:
    import numpy as np
    import sounddevice as sd
except ImportError:
    print("Install: pip install sounddevice numpy", file=sys.stderr)
    sys.exit(1)

SAMPLE_RATE = 16000
CHUNK_MS = 100
CHUNK_SAMPLES = int(SAMPLE_RATE * CHUNK_MS / 1000)


def rms(chunk: np.ndarray) -> float:
    """Root mean square (normalized 0-1 for int16)."""
    return np.sqrt(np.mean((chunk.astype(np.float64) / 32768) ** 2))


def record_until_silence(
    out_path: str,
    silence_threshold: float = 0.01,
    silence_duration: float = 1.5,
    max_duration: float = 60.0,
    verbose: bool = True,
) -> bool:
    """Record until silence_duration seconds of silence, or max_duration reached."""
    silence_chunks = int(silence_duration * 1000 / CHUNK_MS)
    max_chunks = int(max_duration * 1000 / CHUNK_MS)
    chunks_recorded: list = []

    def callback(indata, frames, time_info, status):
        if status:
            print(status, file=sys.stderr)
        chunks_recorded.append(indata[:, 0].copy())

    if verbose:
        print("Listening... speak when ready.")
    stream = sd.InputStream(
        samplerate=SAMPLE_RATE,
        channels=1,
        dtype=np.int16,
        blocksize=CHUNK_SAMPLES,
        callback=callback,
    )
    stream.start()

    # Play inviting sound exactly when recording starts (non-blocking)
    try:
        subprocess.Popen(
            ["afplay", "/System/Library/Sounds/Glass.aiff"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        pass

    try:
        started = False
        while len(chunks_recorded) < max_chunks:
            sd.sleep(CHUNK_MS)
            if len(chunks_recorded) < silence_chunks:
                continue
            recent = np.concatenate(chunks_recorded[-silence_chunks:])
            level = rms(recent)
            if level > silence_threshold:
                started = True
            elif started and level < silence_threshold:
                break
    except KeyboardInterrupt:
        pass
    finally:
        stream.stop()
        stream.close()
        # Play sound immediately so user knows recording stopped
        if chunks_recorded:
            try:
                subprocess.run(
                    ["afplay", "/System/Library/Sounds/Pop.aiff"],
                    capture_output=True,
                    timeout=2,
                )
            except (FileNotFoundError, subprocess.TimeoutExpired):
                pass

    if not chunks_recorded:
        return False

    audio = np.concatenate(chunks_recorded)
    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(audio.tobytes())

    return True


def main():
    p = argparse.ArgumentParser(description="Record with VAD - stops on silence")
    p.add_argument("-o", "--output", default="/tmp/my_speech.wav", help="Output WAV path")
    p.add_argument("-t", "--threshold", type=float, default=0.008, help="Silence threshold (RMS, 0-1)")
    p.add_argument("-s", "--silence", type=float, default=1.5, help="Seconds of silence to stop")
    p.add_argument("-m", "--max", type=float, default=60.0, help="Max recording seconds")
    p.add_argument("-q", "--quiet", action="store_true", help="Suppress messages")
    args = p.parse_args()

    ok = record_until_silence(
        args.output,
        silence_threshold=args.threshold,
        silence_duration=args.silence,
        max_duration=args.max,
        verbose=not args.quiet,
    )
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
