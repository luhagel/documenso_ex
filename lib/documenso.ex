defmodule Documenso do
  @moduledoc """
  A client for the [Documenso](https://documenso.com) API v2.

  ## Configuration

      config :documenso_ex,
        api_key: "api_...",
        # Only for self-hosted instances. Defaults to https://app.documenso.com
        instance_url: "https://sign.example.com"

  Every function also accepts `api_key:` and `instance_url:` options, which win over the config.
  API keys belong to a single Documenso team, so this is how you work with several teams.
  All other options go to `Req`, such as `receive_timeout:`.

  ## Conventions

    * Maps are API data. They are sent as they are, in the camelCase of the
      [API reference](https://openapi.documenso.com). Keyword lists are options.
    * Required IDs are positional arguments. Envelope IDs are strings like
      `"envelope_abc123"`, recipient and field IDs are integers.
    * Functions return `{:ok, body}` with the decoded response body, or
      `{:error, exception}`, which is a `Documenso.Error` when the API answered.
      The `!` variants return the body or raise.

  Use `request/2` for endpoints this library doesn't wrap yet.
  """

  @doc """
  Builds the `Req.Request` used for every call.
  """
  def new(options \\ []), do: Documenso.Api.new(options)

  @doc """
  Calls any API v2 endpoint. `path` is relative to `/api/v2`.

      Documenso.request("/folder")
      Documenso.request("/envelope/cancel", method: :post, json: %{envelopeId: "envelope_abc123"})
  """
  def request(path, options \\ []), do: Documenso.Api.request(path, options)

  @doc """
  Same as `request/2`, but returns the body or raises.
  """
  def request!(path, options \\ []), do: Documenso.Api.request!(path, options)
end
