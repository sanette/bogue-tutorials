(lang dune 3.2)
(name bogue-tutorials)
(version "0.2.0")
(generate_opam_files true)
(source (github sanette/bogue-tutorials))
(authors "San Vũ Ngọc")
(maintainers "San Vũ Ngọc")
(license CC-BY-NC-4.0 Apache-2.0)
(documentation https://sanette.github.io/bogue-tutorials/bogue-tutorials/index.html)
(formatting disabled)

(package
 (name bogue-tutorials)
 (synopsis "Bogue Tutorials")
 (description "Several tutorials for learning how to create GUIs with Bogue")
 (depends
  (dune :build)
  (bogue (>= 20240224)))
 (tags
  (gui bogue tutorial)))
