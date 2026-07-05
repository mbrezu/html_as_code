defmodule HtmlAsCodeTest do
  use ExUnit.Case
  doctest HtmlAsCode
  
  use HtmlAsCode

  test "basic" do
    ast = div class: "container", id: "test" do
    end 
    expect(ast, "<div class=\"container\" id=\"test\"></div>")
  end

  test "without body" do
    ast = div class: "container", id: "test"
    expect(ast, "<div class=\"container\" id=\"test\"></div>")
  end

  test "without attributes" do
    ast = div do
    end
    expect(ast, "<div></div>")
  end

  test "empty" do
    ast = div()
    expect(ast, "<div></div>")
  end

  test "nested" do
    ast = div class: "container", id: "test" do
      div do
        img src: "image.png"
      end
      p "Text"
    end
    expect(ast, "<div class=\"container\" id=\"test\"><div><img src=\"image.png\"></div><p>Text</p></div>")
  end

  test "void" do
    ast = img src: "image.png"
    expect(ast, "<img src=\"image.png\">")
  end

  test "script" do
    ast = script src: "myscript.js"
    expect(ast, "<script src=\"myscript.js\"></script>")
  end
  
  test "boolean attributes" do
    ast = div filtered_out: nil, also_filtered_out: false, included: true
    expect(ast, "<div included></div>")
  end

  test "attributes with dashes" do
    ast = div "has-dashes": "yes"
    expect(ast, "<div has-dashes=\"yes\"></div>")
  end

  test "safe/raw html" do
    ast = div do {:safe, "&nbsp;"} end
    expect(ast, "<div>&nbsp;</div>")
  end

  defp expect(ast, expected_result) do
    assert (ast |> render |> IO.iodata_to_binary) == expected_result
  end
end
