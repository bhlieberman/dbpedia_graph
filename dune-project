(lang dune 3.16)

(using melange 0.1)

(name graph)

(generate_opam_files true)

(source
 (github bhlieberman/dbpedia_graph))

(authors "Ben Lieberman")

(maintainers "Ben Lieberman")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name graph)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
