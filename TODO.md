- [ ] should add our macros to `locals_without_parens` in `.formatter.exs`
    - factor out the tags, use the fact that `.formatter.exs` is an Elixir file
      ```elixir
      [
        locals_without_parens: [
            div: 1,
            div: 2,
            p: 1,
            p: 2,
            span: 1,
            span: 2
        ]
      ]
      ```
      , but the list is generated from tags
