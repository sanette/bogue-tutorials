(lang dune 3.7)
(name bogue-tutorials)
(generate_opam_files true)
(source (github sanette/bogue-tutorials.git))
(authors "San Vũ Ngọc")
(maintainers "San Vũ Ngọc")
(license CC-BY-NC-4.0_and_Apache-2.0)

(documentation https://url/to/documentation)

(package
 (name bogue-tutorials)
 (synopsis "Bogue Tutorials")
 (description "Several tutorials for learning how to create GUIs with Bogue")
 (depends (bogue (>= 20221112)))
 (tags
  (bogue tutorial)))
