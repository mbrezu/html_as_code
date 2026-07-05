defmodule HtmlAsCode do
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [div: 2]

      import HtmlAsCode
    end
  end

  @tags ~w(html head body title meta link style script)a ++
          ~w(header footer main nav section article aside div span p)a ++
          ~w(h1 h2 h3 h4 h5 h6)a ++
          ~w(ul ol li dl dt dd)a ++
          ~w(table thead tbody tfoot tr th td caption colgroup col)a ++
          ~w(form input textarea button select option optgroup label fieldset legend)a ++
          ~w(img picture source audio video track canvas iframe embed object)a ++
          ~w(a em strong b i u s small sub sup mark code pre kbd samp var q blockquote cite abbr address time data)a ++
          ~w(br hr wbr)a

  @void_tags MapSet.new(~w(
    area base br col embed hr img input
    link meta source track wbr
  )a)

  defp children_from_body({:__block__, _, exprs}), do: exprs
  defp children_from_body(expr), do: [expr]

  defp normalize([]), do: {[], []}
  defp normalize([[do: body]]), do: {[], children_from_body(body)}
  defp normalize([attrs]) when is_list(attrs), do: {attrs, []}
  defp normalize([child]), do: {[], [child]}
  defp normalize([attrs, [do: body]]), do: {attrs, children_from_body(body)}

  defp emit(tag, {attrs, children}) do
    quote bind_quoted: [
            tag: tag,
            attrs: attrs,
            children: children
          ] do
      {tag, attrs, children}
    end
  end

  for tag <- @tags do
    defmacro unquote(tag)() do
      emit(unquote(tag), normalize([]))
    end

    defmacro unquote(tag)(arg) do
      emit(unquote(tag), normalize([arg]))
    end

    defmacro unquote(tag)(arg1, arg2) do
      emit(unquote(tag), normalize([arg1, arg2]))
    end
  end

  def render(node)

  def render(nil), do: []
  def render(false), do: []

  def render({tag, attrs, children}) do
    if MapSet.member?(@void_tags, tag) do
      [
        "<",
        Atom.to_string(tag),
        render_attrs(attrs),
        ">"
      ]
    else
      [
        "<",
        Atom.to_string(tag),
        render_attrs(attrs),
        ">",
        Enum.map(children, &render/1),
        "</",
        Atom.to_string(tag),
        ">"
      ]
    end
  end

  def render({:safe, iodata}), do: iodata
  def render(text) when is_binary(text), do: escape(text)

  def render(nodes) when is_list(nodes) do
    Enum.map(nodes, &render/1)
  end

  defp render_attrs([]), do: []

  defp render_attrs(attrs) do
    attrs
    |> Enum.filter(fn {_k, v} -> v end)
    |> Enum.map(fn
      {k, true} ->
        [" ", Atom.to_string(k)]

      {k, v} ->
        [" ", Atom.to_string(k), "=\"", escape(to_string(v)), "\""]
    end)
  end

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
