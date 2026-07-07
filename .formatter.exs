# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens:
    Code.eval_file("lib/html_tags.exs")
    |> elem(0)
    |> Enum.flat_map(fn tag ->
      [{tag, 1}, {tag, 2}]
    end)
]
