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

  (** Does not yet handle the redirect/upgrade to HTTPS... *)
let retrieve_link url =
  Client.get
    ?headers:(Some Header.(of_list [ ("Accept", "text/turtle") ]))
    Uri.(of_string url)
  >>= fun (resp, body) ->
  Lwt_io.write_int Lwt_io.stdout (Response.(status resp) |> Code.code_of_status)
  |> ignore;
  Cohttp_lwt.Body.(to_string body)

let urls =
  page_subjs
  |> List.map (fun s -> String.sub s 1 (String.length s - 2))
  |> Lwt_list.map_p (fun s -> retrieve_link s)
