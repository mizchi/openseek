# Transcript review replay (development only)

This harness mounts the production MoonBit frontend and stylesheet manifest.
It injects synthetic OpenSeek host events; it does not execute tools or establish
real engine timing. There are no alternate component trees or CSS variants.

Run `just replay` at the repository root, then open
`http://127.0.0.1:5177/desktop/frontend/replay/index.html?device=device-a&provider=openseek`.

Open Transcript review. Start next exchange, show tool activity, optionally
stream chunks, then finish or fail. Expand the activity to inspect narration,
requests, and results. Try narrow viewport and keyboard focus on a user prompt.

The accepted design groups prompt and answer, uses the existing final Copy
footer as the exchange boundary, and folds a whole work response under its
step/count/verbatim preview. Step commit clocks and repeated ordinals are absent.
Send timestamps are available on hover/focus (visible on devices without hover).
Tool elapsed time is omitted because the shared projection has no reliable
execution timing. Approval controls and terminal errors remain separate surfaces.

The fixture exercises OpenSeek tool activity, streaming, success/failure, and
narrow layout. It does not establish Codex host behavior, real duration, or
native platform behavior. Both providers reuse the changed transcript component.

Exploratory A/B versions are preserved at tag
`desktop-transcript-prototype-exploration`. The final harness lives only on
`codex/desktop-next-replay`; production changes belong to PR #1351.
