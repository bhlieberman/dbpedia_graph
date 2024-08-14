let () =
   let body = Lwt_main.run Graph.urls in
   List.iter print_endline body

