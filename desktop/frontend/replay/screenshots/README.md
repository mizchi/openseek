# PR #1351 screenshot evidence

These are unedited 1280 × 720 captures of the real MoonBit desktop frontend,
using the replay's synthetic OpenSeek events. They are not mockups or evidence
that real tools ran.

- `before.jpg`: main at `66b50a737a404b4a8876bef371a9a41b7bb918f8`.
- `after-expanded.jpg`: PR transcript renderer and styles at `5ceae83`, activity expanded.
- `after-collapsed.jpg`: the same PR state with its activity collapsed.

The before build restored all three production files changed by the PR from
main before compiling: the shared transcript view, transcript CSS, and composer
CSS. All other production sources were identical to that main revision.
The original PR files were restored after the baseline build.

Both runs used the same fixture and sequence: open Transcript review → start
next exchange → show tool activity → finish. Fixture timestamps were fixed to
2026-09-08T03:00:00Z for the new exchange and the same preceding history.
The expanded comparison keeps individual tool request/result disclosures closed
on both sides. The screenshot controller and its synthetic-data disclaimer are
visible. Temporary capture switches are not part of the retained replay.
