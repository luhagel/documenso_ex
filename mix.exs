defmodule Documenso.MixProject do
  use Mix.Project

  @source_url "https://github.com/luhagel/documenso_ex"
  @version "0.4.2"

  def project do
    [
      app: :documenso_ex,
      version: @version,
      elixir: "~> 1.17",
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.7 and >= 0.7.2"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:plug, "~> 1.19", only: :test}
    ]
  end

  defp description do
    "A thin layer around the documenso.com API"
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hex.pm/packages/documenso_ex",
        "Contact" => "https://bsky.app/profile/luhagel.com"
      }
    }
  end
end
