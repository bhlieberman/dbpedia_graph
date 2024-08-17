open! Core
open! Bonsai
open! Bonsai_web

let me =
  object%js (self)
    val name = "Ben" [@@readwrite]
    method get = self##.name
    method set str = self##.name := str
  end

let textEx = Vdom.Node.text me##.name

let nameField =
  Bonsai.const
    Vdom.Node.(
      div
        ~attrs:[ Vdom.Attr.class_ "" ]
        [
          p [ textEx ];
          span [ text "Who I am " ];
          button
            ~attrs:[ Vdom.Attr.on_click (fun _e -> Effect.alert "clicked!") ]
            [ text "Click me!" ];
        ])

let () = Start.start ?bind_to_element_with_id:(Some "root") nameField
