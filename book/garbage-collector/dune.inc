(alias
 (name runtest)
 (deps
  (:x README.md)
  (package async)
  (package core)
  (package core_bench)
  (package mdx)
  (package ppx_jane)
  (:y3 examples/barrier_bench/barrier_bench.ml)
  (:y2 examples/barrier_bench/dune)
  (:y1 examples/finalizer/dune)
  (:y0 examples/finalizer/finalizer.ml)
  (source_tree examples/barrier_bench)
  (source_tree examples/finalizer)
  prelude.ml)
 (locks ../../global-lock)
 (action
  (progn
   (run ocaml-mdx test --prelude=prelude.ml --direction=to-md %{x})
   (diff? %{x} %{x}.corrected)
   (diff? %{y3} %{y3}.corrected)
   (diff? %{y2} %{y2}.corrected)
   (diff? %{y1} %{y1}.corrected)
   (diff? %{y0} %{y0}.corrected))))

(alias
 (name runtest-all)
 (deps
  (:x README.md)
  (package async)
  (package core)
  (package core_bench)
  (package mdx)
  (package ppx_jane)
  (:y3 examples/barrier_bench/barrier_bench.ml)
  (:y2 examples/barrier_bench/dune)
  (:y1 examples/finalizer/dune)
  (:y0 examples/finalizer/finalizer.ml)
  (source_tree examples/barrier_bench)
  (source_tree examples/finalizer)
  prelude.ml)
 (locks ../../global-lock)
 (action
  (progn
   (run ocaml-mdx test --prelude=prelude.ml --direction=to-md
     --non-deterministic %{x})
   (diff? %{x} %{x}.corrected)
   (diff? %{y3} %{y3}.corrected)
   (diff? %{y2} %{y2}.corrected)
   (diff? %{y1} %{y1}.corrected)
   (diff? %{y0} %{y0}.corrected))))
