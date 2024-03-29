(** {0 Bogue-tutorial — A simple counter.} **)

(**

   If you already followed the {{!page-hello}Hello world} tutorial, you know how
   to display widgets. But what about user interaction?

   In this tutorial, in the purest tradition of GUI tutorials, we will create a
   small app displaying the number of requested cookies; and the user can
   request more by clicking a button.

{1 Displaying the Widgets}

   We need a label with the word "Cookies", another one displaying the number of
   cookies, and a button displaying the text "Click for more". So we have 3
   widgets. Let's place them horizontally in a layout, using the function
   [Layout.flat_of_w].

   +SIDE:begin Remember that Bogue uses the "housing" metaphor. The function
   [flat_of_w] (for: "flat of widgets") constructs a flat house from a list of
   widgets. Each widget will be installed in a room, and the house (of type
   [Layout.t]) is built by placing the rooms next to each other. +SIDE:end

   Ok, so let's try this.

**)

(* +CODE:begin *)
open Bogue
module W = Widget

let () =
  let label = W.label "Cookies:" in
  let count = W.label "0" in
  let button = W.button "Click for more" in
  Layout.flat_of_w ~name:"Counter tutorial"
    ~align:Draw.Center [label; count; button]
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(** Notice how we aliased the [Widget] module by [W]. This saves space and time,
    and improves readability.

    +SIDE:begin
    We used two optional arguments to [flat_of_w]. The [~name] will be displayed
    as the window name by your window manager. The [~align] parameter ensures
    that the 3 widgets are vertically centered (the default would by to align
    them by their tops. Try removing this option to see the difference.)
   +SIDE:end

    Here is what we get:

    +IMAGE:"counter.png"

    Of course, we didn't code any logic or user interaction. So this is just a
    dumb GUI that does nothing!

{1 The logic}

    When designing a GUI, it's often useful to do the opposite: try to think
    about the logic, without worrying about display. Well, in our case the logic
    is really minimal:

    We need a mutable variable for the number of cookies:

**)

(* +CODE:begin *)
let x = ref 0
(* +CODE:end *)

(**
   and a function to increase this:

**)

(* +CODE:begin *)
let add_cookie () = incr x
(* +CODE:end *)

(**
   That's about it for the pure logic. Of course, in a real app we would do
   something with [x], for instance order the correct amount of chocolate chips.

**)


(** {1 Connecting the widgets}

    It remains to give life to our GUI inhabitants! The [button] widget should
    be able to talk to the [count] widget. How do we do this?

    There are two aspects:
    + Update the widgets according to our logic
    + React to user input

    In our case, the [count] widget must be updated when [x] changes. Let's
    write a generic function for this:
**)

(* +CODE:begin *)
let update c n =
  W.set_text c (string_of_int n)
(* +CODE:end *)

(**
   +SIDE:begin We have in mind that [update] will be called with arguments
   [count !x]. But it could be applied to any type of widget for which the
   function [W.set_text] makes sense. If we wanted to restrict to widgets of
   "label" type, we could have done:

 **)

(* +CODE:begin *)
let _update_label c n =
  Label.set (W.get_label c) (string_of_int n)
(* +CODE:end *)

(**
   +SIDE:end

   Finally, concerning user interaction, well, this is actually easy. The
   function
   {{:http://sanette.github.io/bogue/Bogue.Widget.html#VALbutton}Widget.button}
   has an optional parameter [~action] which executes the function
   [action : bool -> unit] each time the button is activated by the user.

   Here is our complete GUI:

**)
(* +CODE:begin *)
let () =
  let label = W.label "Cookies:" in
  let count = W.label "0  " in
  let action _ = add_cookie (); update count !x in
  let button = W.button ~action "Click for more" in
  Layout.flat_of_w ~name:"Counter tutorial"
    ~align:Draw.Center [label; count; button]
  |> Bogue.of_layout
  |> Bogue.run
(* +CODE:end *)

(**
   +IMAGE:"counter.webp"

   How cool is that! [;)]

**)
