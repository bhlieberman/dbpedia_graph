module Forms = Forms
module Routes = Routes

let server =
  Dream.run ~error_handler:Dream.debug_error_handler
  @@ Dream.logger @@ Dream.memory_sessions @@ Dream.router
  @@ [
       Dream.get "/" (Dream.from_filesystem "assets" "index.html");
       Dream.get "/search" (fun req -> Dream.html @@ Forms.show_form req);
       Dream.post "/search" (fun req -> 
        match%lwt Dream.form req with
        | `Ok ["message", message] -> Dream.html (Forms.show_form ~message req)
        | _ -> Dream.empty `Bad_Request);
      Routes.dbpedia_page
     ]
