# HtmlAsCode

## Introduction

A small package that makes it easy to render HTML directly from Elixir code. 

Basic usage:

```elixir
use HtmlAsCode

ast = div class: "container", id: "test" do
  div do
    img src: "image.png"
  end
  p "Text"
end

ast |> render |> IO.iodata_to_binary
```

See the tests for more examples.

## Installation

The package can be installed
by adding `html_as_code` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:html_as_code, "~> 0.1.0"}
  ]
end
```

