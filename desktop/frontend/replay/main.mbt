///|
/// Throwaway controls only. Desktop's production boot owns all application
/// state and rendering; these fixtures enter through its WebSocket decoder.
extern "js" fn deliver(event : String) -> Bool =
  #| event => globalThis.__desktopReplay.deliver(JSON.parse(event))

///|
extern "js" fn reset() -> Unit =
  #| () => location.reload()

///|
enum Msg {
  Start
  Finish
  Fail
  Reset
}

///|
struct Playback {
  running : Bool
  events : Array[String]
  note : String
} derive(Eq)

///|
fn turn_event(status : String) -> Json {
  let items : Array[Json] = if status == "completed" {
    [
      {
        "type": "agentMessage",
        "id": "answer-a",
        "text": "Task A finished: the fixture result is ready to inspect.",
      },
    ]
  } else {
    []
  }
  let turn : Json = if status == "failed" {
    {
      "id": "turn-a",
      "status": status,
      "items": items,
      "error": {
        "message": "Replay failure: the task could not finish.",
        "codexErrorInfo": null,
        "additionalDetails": null,
      },
    }
  } else {
    { "id": "turn-a", "status": status, "items": items }
  }
  {
    "method": if status == "inProgress" {
      "turn/started"
    } else {
      "turn/completed"
    },
    "params": { "threadId": "replay-a", "turn": turn },
  }
}

///|
fn main {
  @frontend.boot()
  let controls = @rabbita.new(() => {
    let (state, emit) = @rabbita.create_state(
      (
        {
          running: false,
          events: [],
          note: "Open Task A in the real sidebar, then start it here.",
        } : Playback),
      update=(state, msg, _emit) => {
        if msg is Reset {
          reset()
          return (state, @cmd.none)
        }
        let status = match msg {
          Start => "inProgress"
          Finish => "completed"
          Fail => "failed"
          Reset => "completed"
        }
        let event = turn_event(status).stringify()
        if deliver(event) {
          (
            {
              running: msg is Start,
              events: [..state.events, event],
              note: if msg is Start {
                "Now click Task B in the real sidebar. Then finish or fail A here; watch A’s row."
              } else {
                "Inspect A’s sidebar cue while B stays selected. Then open A to inspect the actual transcript. Reset to compare the other outcome."
              },
            },
            @cmd.none,
          )
        } else {
          (
            {
              ..state,
              note: "The fixture connection is not ready yet. Wait for the sidebar, then retry.",
            },
            @cmd.none,
          )
        }
      },
    )
    state.view(state => {
      @html.div([
        @html.strong("Desktop event replay · real MoonBit application"),
        @html.p(
          "1. Open A → 2. Start A → 3. Open B → 4. Finish or fail A → 5. Inspect A. Reset and stay on A to compare foreground behavior.",
        ),
        @html.div([
          @html.button(disabled=state.running, on_click=emit(Start), "Start A"),
          @html.button(
            disabled=!state.running,
            on_click=emit(Finish),
            "Finish A",
          ),
          @html.button(disabled=!state.running, on_click=emit(Fail), "Fail A"),
          @html.button(on_click=emit(Reset), "Reset replay"),
        ]),
        @html.p(state.note),
        @html.details([
          @html.summary("Injected events and scope"),
          @html.p(
            "The application below is production frontend.boot(), production state updates, components and CSS. Only host data is simulated using the existing browser harness. These are synthetic protocol events, not a captured real agent run. No sidebar status or selection is assigned by this panel. Native host notifications and reconnect behavior are outside this replay.",
          ),
          @html.pre(state.events.join("\n\n")),
        ]),
      ])
    })
  })
  controls.mount("replay")
}
