defmodule Documenso.MixProject do
  use Mix.Project

  @source_url "https://github.com/luhagel/documenso_ex"
  @version "0.1.0"

  def project do
    [
      app: :documenso_ex,
      version: @version,
      elixir: "~> 1.17",
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      licenses: ["MIT"],
      links: [
        %{name: "GitHub", url: @source_url},
        %{name: "Docs", url: "https://hex.pm/packages/documenso_ex"},
        %{name: "Contact", url: "https://bsky.social/@luhagel.com"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A thin layer around the documenso.com API"
  end
end
