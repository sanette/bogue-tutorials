(** {0 Bogue-tutorial — Widgets and connections : a graph structure.} *)


(**

   In this tutorial, we will learn what {e connections} are for Bogue, why they
   are needed for user interaction, and how to construct them. We will finish by
   coding a {e complete game}, in the Reversi-Othello style.

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
   selected by the user with the Slider. (Think of a "volume" slider for our
   audio player).

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
   widgets, distributed at arbitrary locations inside your window, and some of
   them are connected together, like the "slider-label" pair. Remember that
   specifying the location of widgets is done via {e Layouts}, but the way
   widgets are connected may have nothing to do with the layout structure: our
   label may be at a very different place from our slider.

   {1 The widget graph}

   Here is a definition for our mathematician self: a (directed) graph, in the
   combinatoric sense, is a set of vertices together with a set of arrows; an
   arrow is a pair (e1,e2), where e1 and e2 are vertices. The presence of the
   pair (e1,e2) in the set of arrows of course means that e1 is connected to e2.

   Thus, we see that the logic of a Bogue app is encoded in the {e Widget
   graph}: vertices are widgets, and arrows are connections!

   Connections are triggered by user interaction. In the case of {e isolated}
   widgets, like the "Play" button above, we can view the action of playing the
   music as a connection from the widget to itself.

   +IMAGE:"graph.png"

   Saying that the {e slider is connected to the label} means that the slider
   waits for user interaction, and reacts by performing an action which involves
   the label: for instance, change the number displayed by the label.

   {1 Why connections?}

   If you go back to our toy examples (the Play Button and the Volume Slider),
   you may wonder why we need to know about connections. These examples simply
   used an [action] parameter, which, in other GUI frameworks, is called a
   "callback".

   Under the hood, Bogue uses connections to perform this, but rather dumb ones:
   an action is merely a connection from a widget to itself. So why do we need
   arbitrary connections?

   The problem with simple "callbacks" like these is that they prevent the
   construction of {e cyclic connections}. Let's give a simple example: suppose
   that the user is also allowed to modify the volume by entering the number
   directly in the text field. Then, the slider should adjust itself to the new
   number, right?

   The first change is to replace the [vol] label by a Text input widget. That's
   easy. But now comes the tricky part: we want to attach to the text input a
   new action which modifies the slider; but the slider was defined with an
   action parameter which modified the text input. Who is defined first?

   This problem is impossible to solve using two [slider_with_action]. Instead,
   it's much easier to think in terms of connections. The graph is as follows:
   two widgets (nodes) and two connections in opposite directions (arrows [c1]
   and [c2]).

   +IMAGE:"graph-volume.png"

   {1 Creating connections}

   It's time to show how we define arbitrary connections in Bogue.  The general
   function for this purpose is
   {{:http://sanette.github.io/bogue/Bogue.Widget.html#VALconnect}[Widget.connect]}. Its
   syntax is

   (* +CODE:begin *)
   let c = W.connect source target action triggers
   (* +CODE:end *)

   This creates a connection [c] from [source] to [target]. Once attached to our
   Bogue app, this connection will execute the [action] as soon as the
   [triggers] events are detected.

   The [action] function for connections is quite specific. It will be called
   with three arguments: [source target event], where [event] is the specific
   event that triggered the action.

   First, let us rewrite the previous "Volume slider+label" app using an
   explicit connection.

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

(** {b Note:} By default, actions run by [connect] are launched in a new thread,
    so that even a slow action will not make the GUI unresponsive. Here, we know
    that our action is very fast, so launching a new thread for every slider
    motion would be overkill. That's why we use [W.connect_main] (which is an
    alias for [W.connect ~priority:W.Main]) to tell Bogue it should run the
    action in the main thread.  *)

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

   {1 A checker game with many connections}

   Let's push the connection logic further. Imagine a checker game with the
   following rules. Coins have a black face and a white face (like in the
   Reversi/Othello game). Each player in turn place their color in any available
   square on the board. Then any coin positioned immediately on the left, right,
   top or bottom of that coin must be flipped to change its color. When the
   board is full, the player with more coins of their color on the board wins.

   +IMAGE:"reversi.jpg"

   Can we code the whole game using connections? Yes, indeed: each square is a
   widget, and we connect it with the 4 neighboring squares: left, up, right,
   down, in order to check whether we need to flip a coin. We also connect it
   with itself, to change its status from empty to black or white, when the user
   clicks on it. That's it!

   +IMAGE:"checkers-4.png"
   The connection graph for a 4 x 4 board.

   Let's code this! We will use a simple Box widget for each square. We need 3
   different states: empty, black, white. In order to draw a colored disc (the
   coin), a simple rounded background with radius [w/2] will do the trick. *)

(* +CODE:begin *)
type state = Empty | Black | White

let w = 30
let h = 30

let black = Style.(of_bg (opaque_bg Draw.black)
                   |> with_border (mk_border ~radius:(w/2) (mk_line ())))
let white = Style.(of_bg (opaque_bg Draw.white)
                   |> with_border (mk_border ~radius:(w/2) (mk_line ())))

let make_style = function
  | Empty -> Style.empty
  | White -> white
  | Black -> black

let make_widgets n =
  let make_row n =
    Array.init n (fun _ ->  W.box ~w ~h ~style:(make_style Empty) ()) in
  Array.init n (fun _ -> make_row n)
(* +CODE:end *)

(** The [make_widgets] function will initialize a array of empty squares. But
    don't have any graphics yet, because we didn't define any layout. Let's do
    this now. Each Box will belong to a layout, and then we group the layouts
    into a square board. To make it more fancy, let us alternate the background
    color of the small layout in order to obtain a nice checkerboard. *)

(* +CODE:begin *)
let dark = Style.(of_bg (opaque_bg Draw.(find_color "saddlebrown")))
let light = Style.(of_bg (opaque_bg Draw.(find_color "bisque")))

let make_layout ws =
  ws
  |> Array.mapi (fun i row ->
      row
      |> Array.mapi (fun j box ->
          let background = if (i+j) mod 2 = 0 then L.style_bg light
            else L.style_bg dark in
          L.resident ~background box))
  |> Array.to_list
  |> List.map (fun row -> L.flat ~margins:0 (Array.to_list row))
  |> L.tower ~margins:0
(* +CODE:end *)

(** Of course our code is not finished, we didn't add any logic yet, but clearly
    we can't resist displaying what we have so far! It's just a matter of a few
    lines: *)

(* +CODE:begin *)
let show_board n =
  let ws = make_widgets n in
  Bogue.(run (of_layout (make_layout ws)))

let () = show_board 8;;
(* +CODE:end *)

(** Here is what this gives:

    +IMAGE:"checkerboard.png" Nice, isn't it? An 8 x 8 checkerboard, where each
    square is a widget.

    Let's code the logic now. Obviously, we need a function that tell us in
    which state a Box is. In a more complicated game I woudl recommend having a
    separate [state array], but here it is enough to check the Box's style.
*)

(* +CODE:begin *)
let get_state box =
  let s = Box.get_style (W.get_box box) in
  if s = Style.empty then Empty
  else if s = black then Black
  else if s = white then White
  else failwith "Unrecognized box style"
(* +CODE:end *)

(** Now, connections. The connection between a square and one of its neighbors
    can be activated only if the source square [b1] is empty, and it consists in
    checking whether the target square [b2] is occupied, and then flip that
    coin. *)

(* +CODE:begin *)
let flip_neighbor b1 b2 _ =
  if get_state b1 = Empty then
    match get_state b2 with
    | White -> Box.set_style (W.get_box b2) black
    | Black -> Box.set_style (W.get_box b2) white
    | _ -> ()

let connect_neighbor b1 b2 list =
  let c = W.connect_main b1 b2 flip_neighbor Trigger.buttons_down in
  list := c :: !list
(* +CODE:end *)

(** Next, we connect the square with itself: we put the coin on the square and
    take turn. *)

(* +CODE:begin *)
let next player = match !player with
  | Empty -> raise (invalid_arg "next player")
  | White -> player := Black
  | Black -> player := White

let add_coin player b _ _ =
  if get_state b = Empty then
    let style = if !player = Black then black else white in
    Box.set_style (W.get_box b) style;
    next player

let connect_self player b list =
  let c = W.connect_main b b (add_coin player) Trigger.buttons_down in
  list := c :: !list
(* +CODE:end *)

(** Finally, we group all the necessary connections {b in the correct
    order}. (Indeed, if you look carefully you will see that we must flip the
    neighbors {e before} placing our coin on the square.) Note also that the
    following function constructs the [list] in reverse order. *)

(* +CODE:begin *)
let make_connections player ws =
  let list = ref [] in
  let n = Array.length ws in
  for i = 0 to n-1 do
    for j = 0 to n-1 do
      connect_self player ws.(i).(j) list;
      let add ii jj = connect_neighbor ws.(i).(j) ws.(ii).(jj) list in
      if i > 0 then add (i-1) j;
      if j > 0 then add i (j-1);
      if i < n-1 then add (i+1) j;
      if j < n-1 then add i (j+1);
    done
  done;
  !list
(* +CODE:end *)

(** That's it! We can run the game! *)

(* +CODE:begin *)
let main n =
  let player = ref (if Random.bool () then Black else White) in
  let ws = make_widgets n in
  let cs = make_connections player ws in
  make_layout ws
  |> Bogue.of_layout ~connections:cs
  |> Bogue.run

let () = main 8;;
(* +CODE:end *)

(** +IMAGE:"reversi.webp"

    Have fun! I didn't think about the strategy to win, did you?

    +SIDE:begin I have no idea if this game already exists! It wouldn't be
    surprising. Let me know! In the meantime I propose to call it {b Sorc},
    because it's "cros" (like the cross of coins we flip) in the {e reverse}
    order...  😉 +SIDE:end

    I leave it to you to make it more polished: add a score line, show whose
    turn it is, etc.

*)

(** {1 Summary}

    Except in very simple cases, where short-hands using callbacks like
    [slider_with_action] may suffice, when designing a GUI one should always
    start by thinking about the {e connection graph}. This is a way to represent
    how widgets talk to each other upon user interaction. The widget graph can
    have any topology (including cycles), and is essentially independent from
    the "Layout tree" described in the {{!page-layouts}Layouts} tutorial.  *)
