# Documenso

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `documenso_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:documenso_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/documenso_ex>.

## Local Development

Create a `config/config.secret.exs` file and set up an api key with documenso.

Example:

```elixir
import Config

config :documenso_ex,
  api_key: "api_123456789"
```
