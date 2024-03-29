(** {0 Bogue tutorial — Self-modifying layouts.}  **)

(**
   {%html:<style>.figure img{max-width:100%;}</style>%}

   Bogue is built upon the simple concept of {e connection}, which allows two
   remote widgets to communicate, and execute an action triggered by some event.
   For instance, a {e Text input} widget can connect to a {e Search engine}
   widget, in order to send it what the user typed at each key press, and in
   turn the {e Search engine} is connected to the {e Display} widget to tell it
   to print the results when they arrive. (See the {{!page-widgets}Widgets}
   tutorial.)

   Things become more involved when the action triggered by the widget wants to
   modify a Layout to which the widget itself belongs... There are two potential
   issues:

   1. {e Destructive connection:} the original widget may be detroyed by its own
   action, hence often a new widget will have to be created again.

   2. {e Recursive connection:} the action has to take care of recreating a new
   connection for the new widget: the function which creates the connection, and
   the function which creates the Layout must be mutually recursive.

   In this tutorial we will see different ways of constructing a very simple GUI
   that has these issues. See {{!page-index}here} for how to use this tutorial.

**)


(**

   {1 The goal}

   Here we will work out a simple example. Our GUI will print a list of random
   integers between 1 and 10; if the user clicks on an integer, the list will be
   replaced by a new list, whose number of elements is precisely the integer
   that was clicked. ({e Spoiler:} see the {!section-video} below!)

   {v
   -------                                           -------
   |  3  |                                           |  5  |
   -------                                           -------
   |  2  |   ==> user clicks on "2"                  |  3  |
   -------   ===> we get a new list of 2 elements:   -------
   |  6  |
   -------
   |  1  |
   -------
v}


**)

(**
   We will propose 4 different ways of doing this. But first, let us introduce
   some common parts.

   In many [Bogue] programs it is useful to alias the most common modules,
   [Widget] and [Layout], so let's start with this:

**)


(* +CODE:begin *)
open Bogue
module W = Widget
module L = Layout
(* +CODE:end *)

(* +HIDE:begin *)
let () = Random.init 123
(* +HIDE:end *)

(**
   {1 Non-GUI first}

   Most of the time, it is advisable to start by thinking about the non-GUI
   parts, as this is the core of the program.

   For our goal, the program deals with lists of integers. Let us name a data
   type for this:

**)
(* +CODE:begin *)
type ilist = int list
(* +CODE:end *)

(**
   Now, here is our data creating function. We need a function that creates a
   new random list of a given length.

**)
(* +CODE:begin *)
let imake len : ilist =
  Array.init len (fun _ -> Random.int 9 + 1)
  |> Array.to_list
(* +CODE:end *)

(**
   {1 The "disconnected" GUI elements}

   Let us now turn to the GUI elements. We need to create a Button widget for
   displaying a given integer. We don't define the button action here, because
   of the mutually recursive issue, we will add it later.

 **)
(* +CODE:begin *)
let make_button i =
  W.button (string_of_int i)
(* +CODE:end *)

(**
   This is enough to create a list of widgets associated with our data:

 **)
(* +CODE:begin *)
let create_widgets il =
  List.map make_button il
(* +CODE:end *)

(**
   With this, we can already display our GUI! But it will do nothing when we
   click on it, because we didn't create any connection:

**)
(* +CODE:begin *)
let () =
  Random.int 9 + 1
  |> imake
  |> create_widgets
  |> L.tower_of_w ~w:200 ~name:"Non-connected GUI"
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(**

   Some explanation:

   - The function
   {{:http://sanette.github.io/bogue/Bogue.Layout.html#VALtower_of_w}[tower_of_w]}
   piles up a list of widgets (our buttons) to create a Layout.

   - Our layout is then upgraded into a Bogue GUI with only one window by
   {{:http://sanette.github.io/bogue/Bogue.Main.html#VALof_layout}[Bogue.of_layout]}.

   If we execute the code above, we see a window like this:

   +IMAGE:"non-connected.png"

   If we click a button, nothing happens, as expected.
**)

(**
   {1 Method 1: mutually recursive functions}

   Let us write a function that connects one button: [make_connection]. The
   parameter [i] is the integer held by the [button] widget. The connection is
   triggered by the [buttons_up] list of events, and results in:

   + creating a new list;
   + updating the layout with the new list.

  {[
      let rec make_connection layout button i =
        let action _ _ _ = update_layout layout (imake i) in
        W.connect_main button button action Trigger.buttons_up
        |> W.add_connection button
    ]}

**)

(**
   {b Remarks:}

   + Notice that the connection has no target widget, hence we connect the
   button to itself.

   + This code easily extends to any kind of widget, but, since we are dealing
   with buttons, it is actually better to use the dedicated function:
   [W.on_button_release], because it will also handle keyboard selection
   (TAB+ENTER). Just write instead:

**)

(* +CODE:begin *)
let rec make_connection layout button i =
  let release _ = update_layout layout (imake i) in
  W.on_button_release ~release button
(* +CODE:end *)

(**
   In order to update the layout, we install the new widgets inside the main
   (window) layout using [set_rooms], and connect them with
   [make_connection]. We also resize the window accordingly thanks to
   [fit_content]. Notice that, by default, [set_rooms] is not executed
   immediately, but synchronized with Bogue's main loop. Therefore, the call to
   [fit_content] must be synchronized as well to make sure it is executed {e
   after} [set_rooms].

**)
(* +CODE:begin *)
and update_layout layout il =
  let widgets = create_widgets il in
  let tower = L.tower_of_w ~w:200 widgets in
  L.set_rooms layout [tower];
  Sync.push (fun () -> L.fit_content ~sep:0 layout);
  List.iter2 (make_connection layout) widgets il
(* +CODE:end *)

(**
   We have now a working GUI! Since the main layout will be populated by
   [update_layout], we just need to initialize it as an [empty] layout. Here we
   don't care about the initial size (200,400) since it will be immediately
   modified by [update_layout].

**)
(* +CODE:begin *)
let () =
  let layout = L.empty ~w:200 ~h:400 ~name:"Method 1: recursive" () in
  let () = Random.int 9 + 1
           |> imake
           |> update_layout layout in
  Bogue.run (Bogue.of_layout layout)
(* +CODE:end *)

(**
   You should see a window like this:

   +IMAGE:"connected.png"

   and clicking on the "2" button should replace the list by a 2-element list:

   +IMAGE:"connected_2.png"

   And the new buttons are again clickable to modify the list. Goal achieved!

**)

(**
   {1 Method 2: use update events to get rid of recursivity!}

   Mutually recursive functions can be hard to debug, especially if your program
   becomes large and the recursivity spreads over many functions.

   In this case it is useful to think of the {e update event} method. The button
   and its parent house share the data via a global variable, and, when clicked,
   the button just needs to ask its parent to update. (Of course, this
   programming style feels less "functional".)

**)

(* +CODE:begin *)
let my_list = ref []
(* +CODE:end *)

(**
   We need to create a widget that will receive the [update] event; let's call
   it [controller]. This [empty] widget just does the logic, it's not associated
   with any graphical element.

**)
(* +CODE:begin *)
let controller = W.empty ~w:0 ~h:0 ()
(* +CODE:end *)

(**
   Now the only thing that the button should do, when clicked, is to send the
   update event to the controller, using [Update.push]. Since there is no
   recursivity, we can define the button {e and} its behaviour when clicked at
   once, using the [~action] parameter.

**)
(* +CODE:begin *)
let make_button i =
  W.button (string_of_int i)
    ~action:(fun _ ->
        my_list := imake i;
        Update.push controller)

let create_widgets il =
  List.map make_button il

let update_layout layout =
  let widgets = create_widgets !my_list in
  let tower = L.tower_of_w ~w:200 widgets in
  L.set_rooms layout [tower];
  Sync.push (fun () -> L.fit_content ~sep:0 layout)
(* +CODE:end *)

(**
   The controller's action needs to know which [layout] to update, so we have to
   create its connection {e after} the layout:

**)
(* +CODE:begin *)
let () =
  let layout = L.empty ~w:200 ~h:400 ~name:"Method 2: update event" () in
  let c = W.connect_main controller controller
      (fun _ _ _ -> update_layout layout) [Trigger.update] in
  my_list := imake (Random.int 9 + 1);
  update_layout layout;
  Bogue.run (Bogue.of_layout ~connections:[c] layout)
(* +CODE:end *)

(**
   Notice how, for a change, we didn't manually add the [c] connection to the
    [controller] widget; instead we pass it to [Bogue.of_layout] which takes
    care of it. This is equivalent.

**)

(**
   {1 Method 3: immediate mode}

   You don't like connections and events? No problem, if the GUI is not too big,
   we can use the so-called "immediate" style.

   {b Immediate vs. retained:} Internet if full of dubious posts about the
   difference between the so-called "immediate mode" and "retained mode", and
   the adepts of the former claim that its detractors don't know what they are
   talking about. Admittedly, the Wikipedia pages for both are (as of 2023) of
   really bad quality. I don't want to enter this debate, so you can remove the
   word "immediate", or replace it with "synchronized" or anything else if you
   prefer.

   The rough idea of the "immediate" programming style is that, instead of
   considering a button (or other widgets) as an active component which sends a
   message or executes an action when pressed (which is the role of Bogue's
   connections), we view it as a passive component which holds a value, and
   whoever wants to use this value can just immediately take it and act with
   it. Since a widget then becomes a plain variable, it is much simpler to
   reason with. In pseudo-code:

   {[ if button.is_pressed then do_this ]}

   The downside is that we don't know when the button state has been modified,
   so we need to poll it continuously. Hence we will implement this style by
   using the [before_display] option of
   {{:http://sanette.github.io/bogue/Bogue.Main.html#VALrun}[Bogue.run]}.

   OK let's start. The creation of buttons cannot be simpler: same as in the
   "disconnected" section.

**)
(* +CODE:begin *)
let make_button i =
  W.button (string_of_int i)

let create_widgets il =
  List.map make_button il
(* +CODE:end *)

(**
   Layouting is also easy. Notice that the [update_layout] function is similar
   to the previous one from Method 2, but now we should not force
   synchronization (it will be automatic).

 **)
(* +CODE:begin *)
let update_layout layout il =
  my_list := il;
  let tower = L.tower_of_w ~w:200 (create_widgets il) in
  L.set_rooms ~sync:false layout [tower];
  L.fit_content ~sep:0 layout
(* +CODE:end *)

(**
   Next, we need a function which tells us which button was pressed (if any, so
   we return an [int option]).

   For this, we query the internals of our main layout as follows.

 **)
(* +CODE:begin *)
let button_clicked room =
  let b = L.widget room in
  W.get_state b

let get_button_from_tower tower =
  let rooms = L.get_rooms tower in
  let rec loop2 = function
    | r::other_rooms, i::other_ints ->
      if button_clicked r then Some i
      else loop2 (other_rooms, other_ints)
    | _ -> None in
  loop2 (rooms, !my_list)
(* +CODE:end *)

(**
   A danger of the "immediate" style is that, if we push the paradigm too far,
   we may be tempted to recreate the whole GUI at each frame, which is not a
   good idea (and Bogue will not like it!). To avoid this, our new [update_list]
   function will return [None] if no button was pressed.

**)
(* +CODE:begin *)
let update_list layout =
  List.hd (L.get_rooms layout)
  |> get_button_from_tower
  |> Option.map imake
(* +CODE:end *)

(**
   In this way, we will be able to call our [update_layout] function only when
   the result of [update_list] is not [None.]

 **)
(* +CODE:begin *)
let () =
  let layout = L.empty ~w:200 ~h:400 ~name:"Method 3: immediate mode" () in
  update_layout layout (imake (Random.int 9 + 1));
  let before_display () =
    update_list layout
    |> Option.iter (update_layout layout) in
  Bogue.run ~before_display (Bogue.of_layout layout)
(* +CODE:end *)

(**
   This works perfectly! No connection, no recursivity, so... do we have a
   winner here?

   Well, you can't win on all fronts; the devil is now transferred into the
   [get_button_from_tower] function. Indeed, this function relies on a
   particular organisation of the layout tree. If we decide to move our list of
   buttons to a different box, or include images for decoration, or add
   tooltips, then the function will probably fail. Bogue's philosophy is rather
   to {e not try} to keep track of the layout tree. Connections are more robust
   because they are attached to the widgets, so whatever the layout we construct
   to host the widgets, the connections will always work.

   {1 Method 4: mixed approach}

   For more complex GUIs we can use a {e mixed approach}, which uses a simple
   button action for implementing a good [get_pressed_button], and then an
   immediate style for [update_layout].

 **)

(* +CODE:begin *)
let pressed_button = ref None
let get_pressed_button () =
  let b = !pressed_button
  in pressed_button := None;
  b

let make_button i =
  W.button (string_of_int i)
    ~action:(fun _ -> pressed_button := Some i)

let create_widgets il =
  List.map make_button il
(* +CODE:end *)

(**
   The new [update_list] function is now very simple:

 **)
(* +CODE:begin *)
let update_list () =
  get_pressed_button ()
  |> Option.map imake
(* +CODE:end *)

(**
   We keep the same [update_layout] function as in the Immediate Method (except
   that we don't need the global variable [my_list] anymore), and the main call
   is essentially the same too:

 **)
(* +CODE:begin *)
let update_layout layout il =
  let tower = L.tower_of_w ~w:200 (create_widgets il) in
  L.set_rooms ~sync:false layout [tower];
  L.fit_content ~sep:0 layout

let () =
  let layout = L.empty ~w:200 ~h:400 ~name:"Method 4: mixed approach" () in
  update_layout layout (imake (Random.int 9 + 1));
  let before_display () =
    update_list ()
    |> Option.iter (update_layout layout) in
  Bogue.run ~before_display (Bogue.of_layout layout)
(* +CODE:end *)

(**
   {1 So what?}

   Some words of conclusion.

   First, if you went through the four methods above, congrats! You now have a
   fairly complete overview of how Bogue works, and you should be able to
   program essentially any kind of GUI.

   Next, don't think that this recursivity problem is just an academic
   issue. (Maybe you noticed the similarity with a {e file chooser}?) In my
   experience, it happens quite often, even in moderately complex GUIs, that
   widgets end up having a circular definition.

   But, finally, which method is the best? I don't really know! I guess it all
   depends on your programming taste and the type of GUI you want to
   construct. Games and tools are very different in spirit. Method 1 is maybe
   more elegant from the viewpoint of functional programming, but tracking the
   cycle of dependencies is often hard in real applications. Method 2 is
   probably the most flexible, the most "Bogue-esque", and adapts to virtually
   all kinds of situations. On the other hand, if you are not used to think in
   terms of interacting objects, and prefer the flow of a usual program, I
   believe that Method 4 is a good choice. The only thing that I don't recommend
   is the 'layout tree parsing' of [get_button_from_tower] from Method
   3. Sometimes you need to inspect the layout tree and that's fine if you have
   a way to certify that the tree structure is invariant, but in most situations
   you should first ask yourself: is there another way?

   {5:video Video}

   +IMAGE:"modif_video.webp"

   Happy Bogue-ing!
**)
