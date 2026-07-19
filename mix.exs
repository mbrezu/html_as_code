defmodule HtmlAsCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :html_as_code,
      version: "0.1.5",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mbrezu/html_as_code",
      package: package(),
      description: "HTML as code in Elixir."
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps,
    do: [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README.md* LICENSE),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mbrezu/html_as_code"}
    ]
  end
end
