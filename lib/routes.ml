let make_dbpedia_url query_param =
  let open Basic_ops in
  let open String in
  let open Re in
  let contains_spaces = contains query_param ' ' in
  let search =
    if contains_spaces then
      let spaces = compile @@ char ' ' in
      replace_string spaces ~by:"_" query_param
    else query_param
  in
  let (r : Dbpedia.subject) =
    Dbpedia.{ uri = "http://dbpedia.org/resource/" ^ search }
  in
  Yojson.Safe.to_string @@ Dbpedia.mkSubject r

let dbpedia_page =
  Dream.(
    get "/about/:query" (fun req ->
        let query = param req "query" in
        json @@ make_dbpedia_url query))
