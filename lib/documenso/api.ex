defmodule Documenso.Api do
  @base_url "https://app.documenso.com/api/v1"

  def new(options \\ []) when is_list(options) do
    token = Application.fetch_env!(:documenso_ex, :api_key)
    base_url = Application.get_env(:documenso_ex, :base_url, @base_url)

    [base_url: base_url, auth: {:bearer, token}]
    |> Keyword.merge(default_options())
    |> Req.new()
    |> Req.Request.append_request_steps(
      post: fn req ->
        with %{method: :get, body: <<_::binary>>} <- req do
          %{req | method: :post}
        end
      end
    )
    |> Req.merge(options)
  end

  @spec request(String.t(), Keyword.t()) :: {:ok, map()} | {:error, map()}
  def request(url, options \\ []),
    do: Req.request(new(url: parse_url(url)), options)

  @spec request!(String.t(), Keyword.t()) :: map()
  def request!(url, options \\ []),
    do: Req.request!(new(url: parse_url(url)), options)

  @doc false
  def default_options, do: Application.get_env(:documenso_ex, :req_options, [])

  defp parse_url(url) when is_binary(url), do: url
end
