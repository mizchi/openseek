# Desktop event replay prototype

Use the stable MoonBit channel, as in repository CI. Run `just replay` from
`desktop/`, then open the URL it prints. This is
throwaway development code, not a shipped frontend entry point.

The MoonBit entry point calls production `@frontend.boot()` and mounts a
separate Rabbita controller. The controller creates synthetic Codex turn
notifications; a browser-only fixture transport delivers them through the
production WebSocket decoder, root update, Codex update, and component tree.
It never assigns application state or renders replacement application UI.
Host RPC responses reuse `DesktopBrowserHarness`, with two stored Codex tasks
and their histories added for this scenario. There is no real agent or host.

## Walkthrough

1. Open Task A using the application sidebar.
2. Press **Start A** in the replay controller.
3. Open Task B using the application sidebar. Optionally type a draft or
   scroll before proceeding.
4. Press **Finish A**. Inspect A's sidebar cue while B stays selected.
5. Open A and inspect its production transcript.
6. Reset and repeat with **Fail A**. Reset and repeat without leaving A to
   compare foreground behavior.

The event disclosure shows the exact synthetic payloads. Reset reloads both
the frontend and fixture host. Standard application browser preferences may
use the application's ordinary browser storage; no host data is persisted.

The question remains open: does the actual feedback leave enough context to
understand background outcomes? This replay validates browser frontend
behavior under these inputs. It does not establish which events every real
failure emits, or cover native host notifications, reconnection, and reload
recovery. No proposed UX change is included.

## Observed playback

The browser walkthrough was exercised for both completion and failure. A's
running indicator remained visible after selecting B and disappeared when the
completion notification arrived. B remained selected. Opening A rendered the
fixture result or failure diagnostic in the production transcript. This
confirms the frontend behavior for these inputs, not a verdict on the UX.

Once a decision is validated, retain this prototype on a throwaway branch as
its evidence; only the agreed product change should enter the main branch.
