defmodule Documenso.WebhookTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Plug.Test

  alias Documenso.Webhook

  describe "verify/2" do
    test "accepts only the configured secret" do
      assert Webhook.verify("test_webhook_secret")
      refute Webhook.verify("wrong")
      refute Webhook.verify(nil)
    end

    test "rejects everything when no secret is set" do
      refute Webhook.verify("", "")
      refute Webhook.verify("anything", nil)
    end
  end

  describe "Plug" do
    defp call(secret_header, options) do
      conn = conn(:post, "/webhooks/documenso", "{}")

      conn =
        if secret_header,
          do: put_req_header(conn, "x-documenso-secret", secret_header),
          else: conn

      Webhook.Plug.call(conn, Webhook.Plug.init(options))
    end

    test "passes requests with the right secret through" do
      refute call("test_webhook_secret", []).halted
    end

    test "halts with a 401 otherwise" do
      for header <- ["wrong", nil] do
        conn = call(header, [])
        assert {conn.halted, conn.status} == {true, 401}
      end
    end

    test "resolves the secret per request" do
      options = [secret: fn conn -> "secret_for_#{conn.request_path}" end]
      refute call("secret_for_/webhooks/documenso", options).halted
    end
  end
end
