let root =
  switch (ReactDOM.querySelector("#root")) {
  | Some(root) => ReactDOM.Client.createRoot(root)
  | None => raise(Not_found)
  };

let render = ReactDOM.Client.render(root, <Hello.Greeting name="Ben" />);
