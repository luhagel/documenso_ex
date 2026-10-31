defmodule Documenso.Recipients do
  @moduledoc """
  Helpers for the recipients of an envelope.
  """

  @doc """
  Builds the link a recipient opens to sign, from the `"token"` that recipients carry in
  API responses and webhook payloads. Takes the `instance_url:` option like every other call.

      iex> Documenso.Recipients.signing_url(%{"token" => "abc123"},
      ...>   instance_url: "https://sign.example.com"
      ...> )
      "https://sign.example.com/sign/abc123"
  """
  @spec signing_url(map(), Keyword.t()) :: String.t()
  def signing_url(%{"token" => token}, options \\ []),
    do: "#{Documenso.Api.instance_url(options)}/sign/#{token}"
end
