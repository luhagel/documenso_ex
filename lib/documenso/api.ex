defmodule Documenso.Api do
  @moduledoc false

  @instance_url "https://app.documenso.com"

  def new(options \\ []) when is_list(options) do
    {client, options} = Keyword.split(options, [:api_key, :instance_url])

    [
      base_url: instance_url(client) <> "/api/v2",
      headers: [authorization: api_key(client)],
      retry: &retry/2
    ]
    |> Keyword.merge(default_options())
    |> Req.new()
    |> Req.merge(options)
  end

  @spec request(String.t(), Keyword.t()) :: {:ok, term()} | {:error, Exception.t()}
  def request(path, options \\ []) do
    [url: path]
    |> Keyword.merge(options)
    |> new()
    |> Req.request()
    |> handle_response()
  end

  @spec request!(String.t(), Keyword.t()) :: term()
  def request!(path, options \\ []), do: path |> request(options) |> unwrap!()

  def unwrap!({:ok, body}), do: body
  def unwrap!({:error, exception}), do: raise(exception)

  def instance_url(client \\ []) do
    if Application.get_env(:documenso_ex, :base_url) do
      raise ArgumentError,
            "`config :documenso_ex, :base_url` was replaced by `:instance_url` in 1.0. " <>
              "Set `instance_url: \"https://sign.example.com\"`, without the /api/v1 suffix."
    end

    client
    |> Keyword.get_lazy(:instance_url, fn ->
      Application.get_env(:documenso_ex, :instance_url, @instance_url)
    end)
    |> String.trim_trailing("/")
  end

  def default_options, do: Application.get_env(:documenso_ex, :req_options, [])

  defp api_key(client) do
    Keyword.get_lazy(client, :api_key, fn -> Application.get_env(:documenso_ex, :api_key) end) ||
      raise ArgumentError,
            "missing Documenso API key. Set `config :documenso_ex, api_key: \"api_...\"` " <>
              "or pass `api_key: \"api_...\"`."
  end

  # Req only retries GETs by default, but v2 sends every write as a POST. A 429 was
  # rejected before it ran, so it is safe to retry whatever the method.
  defp retry(_request, %Req.Response{status: 429}), do: true

  defp retry(%Req.Request{method: :get}, %Req.Response{status: status}),
    do: status in [408, 500, 502, 503, 504]

  defp retry(%Req.Request{method: :get}, %Req.TransportError{reason: reason}),
    do: reason in [:timeout, :econnrefused, :closed]

  defp retry(_request, _response_or_exception), do: false

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) when status in 200..299,
    do: {:ok, body}

  defp handle_response({:ok, %Req.Response{} = response}),
    do: {:error, Documenso.Error.exception(response)}

  defp handle_response({:error, _exception} = error), do: error
end
