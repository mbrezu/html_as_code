# Used by "mix format"
tags =
  Code.eval_file("lib/html_tags.exs")
  |> elem(0)

locals_without_parens =
  Enum.flat_map(tags, fn tag ->
    [{tag, 1}, {tag, 2}]
  end)

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
