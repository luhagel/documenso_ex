if Code.ensure_loaded?(Plug) do
  defmodule Documenso.Webhook.Plug do
    @moduledoc """
    Answers webhook requests with a 401 unless their `X-Documenso-Secret` header matches.

        pipeline :documenso_webhook do
          plug :accepts, ["json"]
          plug Documenso.Webhook.Plug
        end

    The secret defaults to `config :documenso_ex, :webhook_secret`. When teams have their
    own secrets, pass a function that picks one per request:

        plug Documenso.Webhook.Plug, secret: &MyApp.Documenso.webhook_secret/1
    """

    @behaviour Plug

    import Plug.Conn

    @impl true
    def init(options), do: options

    @impl true
    def call(conn, options) do
      received = conn |> get_req_header("x-documenso-secret") |> List.first()

      if Documenso.Webhook.verify(received, expected_secret(conn, options)) do
        conn
      else
        conn |> send_resp(401, "") |> halt()
      end
    end

    defp expected_secret(conn, options) do
      case Keyword.fetch(options, :secret) do
        {:ok, secret} -> secret.(conn)
        :error -> Application.get_env(:documenso_ex, :webhook_secret)
      end
    end
  end
end
