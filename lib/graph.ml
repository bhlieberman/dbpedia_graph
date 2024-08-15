open Cohttp
open Lwt
open Cohttp_lwt_unix
open Rdf

let g = Graph.(open_graph (Iri.of_string "http://dbpedia.org"))

let file =
  In_channel.with_open_text "/home/slothrop/roussel.ttl" (fun ic ->
      In_channel.input_all ic)

let normalized = Utf8.utf8_unescape_to_percent file
let () = Ttl.from_string g normalized

let page_subjs =
  List.map (fun t -> Term.(string_of_term t)) (g.Graph.subjects ())

let page_preds = List.map (fun iri -> Iri.to_string iri) (g.Graph.predicates ())

let page_objs =
  List.map (fun obj -> Term.(string_of_term obj)) (g.Graph.objects ())

let rec http_get_and_follow ~max_redirects uri =
  let open Lwt.Syntax in
  let* ans =
    Client.get
      ?headers:
        (Some
           Header.(
             of_list
               [ ("Accept", "text/turtle"); ("Content-Type", "text/turtle") ]))
      uri
  in
  follow_redirect ~max_redirects uri ans

and follow_redirect ~max_redirects request_uri (response, body) =
  let open Lwt.Syntax in
  let status = Response.status response in
  (* The unconsumed body would otherwise leak memory *)
  let* () =
    if status <> `OK then Cohttp_lwt.Body.drain_body body else Lwt.return_unit
  in
  match status with
  | `OK -> Lwt.return (response, body)
  | `Permanent_redirect | `Moved_permanently ->
      handle_redirect ~permanent:true ~max_redirects request_uri response
  | `Found | `Temporary_redirect ->
      handle_redirect ~permanent:false ~max_redirects request_uri response
  | `Not_found | `Gone -> Lwt.fail_with "Not found"
  | `See_other ->
      handle_redirect ~permanent:true ~max_redirects request_uri response
  | status ->
      Lwt.fail_with
        (Printf.sprintf "Unhandled status: %s"
           (Cohttp.Code.string_of_status status))

and handle_redirect ~permanent ~max_redirects request_uri response =
  if max_redirects <= 0 then Lwt.fail_with "Too many redirects"
  else
    let headers = Response.headers response in
    let location = Header.get headers "location" in
    match location with
    | None -> Lwt.fail_with "Redirection without Location header"
    | Some url ->
        let open Lwt.Syntax in
        let uri = Uri.of_string url in
        let* () =
          if permanent then
            Logs_lwt.warn (fun m ->
                m "Permanent redirection from %s to %s"
                  (Uri.to_string request_uri)
                  url)
          else Lwt.return_unit
        in
        http_get_and_follow uri ~max_redirects:(max_redirects - 1)

let retrieve_link url =
  http_get_and_follow ~max_redirects:3 url >>= fun (_, body) ->
  let open String in
  let url_parts = split_on_char '/' (Uri.to_string url) in
  let len_parts = List.length url_parts - 1 in
  let fname = List.nth url_parts len_parts in
  Lwt_io.with_file
    ?flags:(Some [ Unix.O_CREAT; Unix.O_APPEND; Unix.O_WRONLY ])
    ~mode:Lwt_io.Output (fname ^ ".ttl")
    (fun oc -> Lwt_io.write_lines oc Cohttp_lwt.Body.(to_stream body))

let urls =
  page_subjs
  |> List.map (fun s ->
         String.length s - 2 |> String.(sub s 1) |> Uri.of_string)
  |> Lwt_list.map_s (fun s -> retrieve_link s)
