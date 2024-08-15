let () =
  let body = Lwt_main.run Graph.urls in
  List.iter (fun s -> ignore s) body
