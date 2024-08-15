open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Dbpedia = struct
  type subject = { uri: string; } [@@deriving yojson]
  type predicate = { uri : string; } [@@deriving yojson]
  type rdf_object = { uri : string } [@@deriving yojson]

  let mkSubject = yojson_of_subject
  let mkPred = yojson_of_predicate
  let mkObj = yojson_of_rdf_object
end
