(lang dune 3.0)
(name bogue-tutorials)
(version "0.1.0")
(generate_opam_files true)
(source (github sanette/bogue-tutorials))
(authors "San Vũ Ngọc")
(maintainers "San Vũ Ngọc")
(license CC-BY-NC-4.0_and_Apache-2.0)
(documentation https://sanette.github.io/bogue-tutorials/bogue-tutorials/index.html)
(formatting disabled)

(package
 (name bogue-tutorials)
 (synopsis "Bogue Tutorials")
 (description "Several tutorials for learning how to create GUIs with Bogue")
 (depends
   ocaml
   dune
  (bogue (>= 20221112)))
 (tags
  (bogue tutorial)))
