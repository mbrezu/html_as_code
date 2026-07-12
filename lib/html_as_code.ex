defmodule HtmlAsCode do
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [div: 2]

      import HtmlAsCode
    end
  end

  @tags Code.eval_file("lib/html_tags.exs") |> elem(0)

  @void_tags MapSet.new(~w(
    area base br col embed hr img input
    link meta source track wbr
  )a)

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

  defp is_const_attr({_key, value}), do: is_binary(value) or is_boolean(value)

  defp split_attrs(attrs) do
    {
      attrs |> Enum.filter(&is_const_attr/1),
      attrs |> Enum.filter(&(not is_const_attr(&1)))
    }
  end

  defp emit(tag, {attrs, children}) do
    {const_attrs, var_attrs} = split_attrs(attrs)
    rendered_const_attrs = const_attrs |> render_attrs() |> IO.iodata_to_binary()

    quote bind_quoted: [
            tag: tag,
            rendered_const_attrs: rendered_const_attrs,
            var_attrs: var_attrs,
            children: children
          ] do
      {tag, rendered_const_attrs, var_attrs, children}
    end
  end

  defp normalize([]), do: {[], []}
  defp normalize([[do: body]]), do: {[], children_from_body(body)}

  defp normalize([items]) when is_list(items) do
    attrs = Keyword.delete(items, :do)
    body = Keyword.get(items, :do)

    {attrs, if(body, do: children_from_body(body), else: [])}
  end

  defp normalize([child]), do: {[], [child]}
  defp normalize([attrs, [do: body]]), do: {attrs, children_from_body(body)}

  defp children_from_body({:__block__, _, exprs}), do: exprs
  defp children_from_body(expr), do: [expr]

  def render(node)

  def render(nil), do: []
  def render(false), do: []

  def render({tag, rendered_const_attrs, var_attrs, children}) do
    if MapSet.member?(@void_tags, tag) do
      [
        "<",
        Atom.to_string(tag),
        rendered_const_attrs,
        render_attrs(var_attrs),
        ">"
      ]
    else
      [
        "<",
        Atom.to_string(tag),
        rendered_const_attrs,
        render_attrs(var_attrs),
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
