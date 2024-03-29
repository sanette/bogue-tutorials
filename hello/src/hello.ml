(** {0 Bogue tutorial — Hello world.}
 **)

(**

   In this tutorial we will learn how to open a graphical window displaying a
   short text, like "Hello world". We then take advantage of this to familiarise
   with basic Bogue concepts.

{1 Hello world}

   Let's start right ahead with the "minimal code" mentionned in Bogue's
   {{:https://sanette.github.io/bogue/Principles.html}documentation}:
**)

(* +CODE:begin *)
open Bogue

let () =
  Widget.label "Hello world"
    |> Layout.resident
    |> Bogue.of_layout
    |> Bogue.run
(* +CODE:end *)

(** We can copy this code in an OCaml toplevel and execute it; see
    {{!page-index}here} for general instructions.

    A small window should pop up like this:

    +IMAGE:"hello.png"

    So, how does this work? Let's go through this again line by line.

    First, instead of using the convenient [|>] operator, let's give names to
    the various steps; we have the following equivalent code:

**)

(* +CODE:begin *)
let () =
  let widget = Widget.label "Hello world" in
  let layout = Layout.resident widget in
  let board = Bogue.of_layout layout in
  Bogue.run board
(* +CODE:end *)

(**

   In Bogue, there are mainly two types of objects: {b widgets} and {b
   layouts}. Widgets are small graphics elements (buttons, images, etc.) and
   they can be combined into a Layout. Roughly speaking:

   - widget = content
   - layout = container.

   Here we create only one widget, of [label] type:

{[
  let widget = Widget.label "Hello world" in
]}

   and we install it in a layout, as in single resident:

{[
  let layout = Layout.resident widget in
]}

   Why is this function called "resident"? Well, if you browse
   {{:https://sanette.github.io/bogue/Bogue.html}Bogue's API}, you will notice
   that Bogue uses a "housing" metaphor: a GUI is a big house with inhabitants
   (the widgets) living in various rooms (the layouts).

   For this example, the layout we've just created is the only "room" in our
   house, so we use it to create our "board" (which is our complete GUI):

{[
  let board = Bogue.of_layout layout in
]}

This board can be seen as our application, we run it using:

{[
  Bogue.run board
]}

Simple, isn't it?

{1 More space}

   Well, of course there is more to it. For instance, you may find that the text
   label is a bit tight and needs more space around it. (In other words, the
   resident needs a larger room ;) )

   So let's have a look at the documentation for the function
   {{:https://sanette.github.io/bogue/Bogue.Layout.html#VALresident}Layout.resident}:

{[
 val resident :
    ?name:string -> ?x:int -> ?y:int -> ?w:int -> ?h:int ->
    ?background:background ->
    ?draggable:bool ->
    ?canvas:Draw.canvas ->
    ?keyboard_focus:bool -> Widget.t -> t
]}

   We spot the optional parameters [?w] and [?h] which should set the desired
   widht and height of our layout. Let's try:

**)

(* +CODE:begin *)
let () =
  Widget.label "Hello world"
    |> Layout.resident ~w:300 ~h:150
    |> Bogue.of_layout
    |> Bogue.run
(* +CODE:end *)

(**

   +IMAGE:"hello-wide.png"

{1 Several widgets in a layout}

   Great, but the text feels alone... Suppose we want to display an image below
   our label.

   Can we fit several residents in a room? Well, not really. Strictly speaking,
   a layout can contain only one widget. But, the trick is that, in Bogue, an
   element of type [Layout.t] can also contain a list of layouts; in this case
   we often call it a "house", since it contains a number of "rooms". Let's do
   this.

   +SIDE:begin {b Side-note:} In a layout, rooms can be arbitrarily nested. We
   have here the usual construction for a {e tree} data structure: each node is
   either terminal (and called a leaf, which for us are widgets), or a vertex
   (for us, a layout), pointing to a list of sub-nodes.

   The trunk of the tree (our main house, if you wish), will correspond to the
   layout associated with the window of the GUI. In Bogue we often call this
   special layout the "top layout", or "top house". (Yes, our tree grows
   top-down, like family trees.) See the {{!page-layouts}"Layouts"} tutorial for
   more details. +SIDE:end

   So, we want to display an image below the label. Our label is a widget:
   {[
     let hello = Widget.label "Hello world"
   ]}

   An image is also a widget:
   {[
     let image = Widget.image "bogue-icon.png"
   ]}

   Now, to put one on top of the other, we use the function [Layout.tower_of_w]
   (short for "tower of widget") which constructs a "tower":
**)

(* +CODE:begin *)
let () =
  let hello = Widget.label "Hello world" in
  let image = Widget.image "bogue-icon.png" in
  let layout = Layout.tower_of_w [hello; image] in
  let board = Bogue.of_layout layout in
  Bogue.run board
(* +CODE:end *)


(**

   This opens a window like this:

   +IMAGE:"hello-image.png"

   What exactly does this function [Layout.tower_of_w] do? It takes a list of
   widgets, and for each one, installs it in a room, as a resident. Then it
   constructs a new layout by piling up the rooms vertically.

   The doc for
   {{:https://sanette.github.io/bogue/Bogue.Layout.html#VALtower_of_w}[tower_of_w]}
   shows interesting options. For instance, to center everything horizontally,
   use [~align:Draw.Center]:

   +IMAGE:"hello-image-center.png"

{1 Exercise: vertical text}

What about applying what we've just learned to write "Hello world" {e vertically}?

{b Solution:} Let's use [Layout.tower_of_w] to build a "tower" of letters.

**)

(* +CODE:begin *)
let vertical text =
  Array.init (String.length text) (String.get text)
  |> Array.to_list
  |> List.map (String.make 1)
  |> List.map Widget.label
  |> Layout.tower_of_w

let () =
  vertical "Hello world"
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(**

   +IMAGE:"hello-vertical.png"

   Et voila !

   We now know enough Bogue to play with layouts full of text and image. But, of
   course, a crucial part of a GUI is missing: user interaction. This will be
   the goal of the {{!page-counter}"counter"} tutorial.

**)
