(** {0 Bogue-tutorial — Widgets and connections : a graph structure.} *)


(**

In this tutorial, we will learn what {e connections} are for Bogue, why they are
needed for user interaction, and how to construct them.

   {1 Widgets and actions }

The role of a GUI is to perform specific actions in response to user
interaction. For instance, play a music when the user press the "Play"
button. In order to do this, our Bogue app must wait until it detects a mouse
click at the right place, and then run the action.

In Bogue, user interaction is done at the level of {b Widgets}. For instance,
one can use a Button widget to perform that task, namely using
{{:http://sanette.github.io/bogue/Bogue.Widget.html#VALbutton}[Widget.button]}
with the [~action] parameter. *)

(* +CODE:begin *)
open Bogue
module W = Widget
module L = Layout

let () =
  W.button ~action:(fun _ -> print_endline "Playing!") "Play"
  |> L.resident ~w:100 ~h:30
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(**
In most cases, widgets don't act alone. For instance, a Slider widget can be
connected to a Label widget in order to display on the Label the quantity
selected by the user with the Slider. (Think of a "volume" slider for our audio
player).

 *)

(* +CODE:begin *)
let () =
  let label = W.label "Volume:" in
  let vol = W.label "0    " in
  let slider = W.slider_with_action ~action:(fun v ->
                   W.set_text vol (string_of_int v)) ~value:0 100 in
  L.flat ~align:Draw.Center
    [L.resident ~background:L.theme_bg slider;
     L.flat_of_w [label; vol]]
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(**

+IMAGE:"volume-slider.png"

For this purpose, Bogue introduces the concept of {b connections} between
widgets.

Take a step back and try to visualize a whole, large GUI app. There are many
widgets, distributed at arbitrary locations inside your window, and some of them
are connected together, like the "slider-label" pair. Remember that specifying
the location of widgets is done via {e Layouts}, but the way widgets are
connected may have nothing to do with the layout structure: our label may be at
a very different place from our slider.

{1 The widget graph}

Here is a definition for our mathematician self: a (directed) graph, in the
combinatoric sense, is a set of vertices together with a set of arrows; an arrow
is a pair (e1,e2), where e1 and e2 are vertices. The presence of the pair
(e1,e2) in the set of arrows of course means that e1 is connected to e2.

Thus, we see that the logic of a Bogue app is encoded in the {e Widget graph}:
vertices are widgets, and arrows are connections!

Connections are triggered by user interaction. In the case of {e isolated} widgets,
like the "Play" button above, we can view the action of playing the music as a
connection from the widget to itself.

+IMAGE:"graph.png"

Saying that the {e slider is connected to the label} means that the slider waits
for user interaction, and reacts by performing an action which involves the
label: for instance, change the number displayed by the label.

{1 Why connections?}

If you go back to our toy examples (the Play Button and the Volume Slider), you
may wonder why we need to know about connections. These examples simply used an
[action] parameter, which, in other GUI frameworks, is called a "callback".

Under the hood, Bogue uses connections to perform this, but rather dumb ones: an
action is merely a connection from a widget to itself. So why do we need
arbitrary connections?

The problem with simple "callbacks" like these is that they prevent the
construction of {e cyclic connections}. Let's give a simple example: suppose
that the user is also allowed to modify the volume by entering the number
directly in the text field. Then, the slider should adjust itself to the new
number, right?

The first change is to replace the [vol] label by a Text input widget. That's
easy. But now comes the tricky part: we want to attach to the text input a new
action which modifies the slider; but the slider was defined with an action
parameter which modified the text input. Who is defined first?

This problem is impossible to solve using two [slider_with_action]. Instead,
it's much easier to think in terms of connections. The graph is as follows: two
widgets (nodes) and two connections in opposite directions (arrows [c1] and
[c2]).

+IMAGE:"graph-volume.png"

{1 Creating connections}

It's time to show how we define arbitrary connections in Bogue.  The general
function for this purpose is
{{:http://sanette.github.io/bogue/Bogue.Widget.html#VALconnect}[Widget.connect]}. Its syntax is

(* +CODE:begin *)
let c = W.connect source target action triggers
(* +CODE:end *)

This creates a connection [c] from [source] to [target]. Once attached to our
Bogue app, this connection will execute the [action] as soon as the [triggers]
events are detected.

The [action] function for connections is quite specific. It will be called with
three arguments: [source target event], where [event] is the specific event that
triggered the action.

First, let us rewrite the previous "Volume slider+label" app using an explicit
connection.

  *)

(** {2 Triggers}

    Here is the usual list of events that a slider normally responds to. In
    recent Bogue versions (>= 20240121), this can be obtained by the variable
    [Slider.triggers]. *)
(* +CODE:begin *)
let slider_triggers =
  let open Trigger in
  List.flatten [buttons_down; buttons_up; pointer_motion; [Tsdl.Sdl.Event.key_down]]
(* +CODE:end *)

(** {2 Action}

    Here is the action that will be used for our connection. Notice that it is a
    pure function, contrary to the action used in [slider_with_action] above,
    which had to access the closure (external variable) [vol]. We don't care
    about which specific event triggered the action, hence the variable [_ev] is
    not used.  *)
(* +CODE:begin *)
let update_text src dst _ev =
  let v = Slider.value (W.get_slider src) in
  W.set_text dst (string_of_int v)
(* +CODE:end *)

(** {2 The connected Volume slider (one way)}

And here is the Bogue app. Notice the [~connections:[c]] argument when
constructing our board.  *)
(* +CODE:begin *)
let () =
  let label = W.label "Volume:" in
  let vol = W.label "  0  " in
  let slider = W.slider ~value:0 100 in
  let c = W.connect_main slider vol update_text slider_triggers in
  L.flat ~align:Draw.Center
    [L.resident ~background:L.theme_bg slider;
     L.flat_of_w [label; vol]]
  |> Bogue.of_layout ~connections:[c]
  |> Bogue.run
(* +CODE:end *)

(** {b Note:} By default, actions run by [connect] are launched in a new
    thread, so that even a slow action will not make the GUI
    unresponsive. Here, we know that our action is very fast, so
    launching a new thread for every slider motion would be
    overkill. That's why we use [W.connect_main] (which is an alias for
    [W.connect ~priority:W.Main]) to tell Bogue it should run the action
    in the main thread.
 *)

(** {2 The two-way connected Volume slider}

Finally, as promised above, let's use connections to obtain a bi-directional
connection between a Volume slider and a Text input.

We define the list of events that should trigger the connection from the
Text_input side, and the action to perform.
*)

(* +CODE:begin *)
let text_triggers = Tsdl.Sdl.Event.[text_editing; text_input; key_down; key_up]

let update_slider src dst _ev =
  match int_of_string_opt (W.get_text src) with
  | Some v -> if v >=0 && v <= 100 then Slider.set (W.get_slider dst) v
  | None -> print_endline "Invalid entry"
(* +CODE:end *)

(** And here is our first multi-directional application! *)

(* +CODE:begin *)
let () =
  let align = Draw.Center in
  let label = W.label "Volume:" in
  let input = W.text_input ~text:"0" ~prompt:"100" () in
  let slider = W.slider ~value:0 100 in
  let c1 = W.connect_main slider input update_text slider_triggers in
  let c2 = W.connect_main input slider update_slider text_triggers in
  L.flat ~align [L.resident ~background:L.theme_bg slider;
                 L.flat_of_w ~align  [label; input]]
  |> Bogue.of_layout ~connections:[c1; c2]
  |> Bogue.run
(* +CODE:end *)

(**
 +IMAGE:"digraph-slider.webp"

 Impressive, isn't it?  😉

{1 Summary}

Except in very simple cases, where shorthands using callbacks like
[slider_with_action] may suffice, when designing a GUI one should always start
by thinking about the {e connection graph}. This is a way to represent how
widgets talk to each other upon user interaction. The widget graph can have any
topology (including cycles), and is essentially independent from the "Layout
tree" described in the {{!page-layouts}Layouts} tutorial.  *)
