defmodule DocumensoTest do
  # Not async: one test changes the application env.
  use ExUnit.Case
  doctest Documenso.Recipients

  describe "new/0,1" do
    test "delegates to Documenso.Api.new with no options" do
      assert Documenso.new().options == Documenso.Api.new().options
    end

    test "delegates to Documenso.Api.new with options" do
      opts = [receive_timeout: 1234]
      assert Documenso.new(opts).options == Documenso.Api.new(opts).options
    end
  end

  describe "request/2" do
    test "sends the raw API key to the v2 API" do
      Req.Test.stub(Documenso, fn conn ->
        assert conn.host == "sign.example.com"
        assert conn.request_path == "/api/v2/folder"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["api_team"]
        Req.Test.json(conn, %{"data" => []})
      end)

      assert {:ok, %{"data" => []}} =
               Documenso.request("/folder",
                 api_key: "api_team",
                 instance_url: "https://sign.example.com/"
               )
    end

    test "turns error responses into a Documenso.Error" do
      Req.Test.stub(Documenso, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "message" => "Input validation failed",
          "code" => "BAD_REQUEST",
          "issues" => [%{"path" => ["envelopeId"], "message" => "Required"}]
        })
      end)

      assert {:error, %Documenso.Error{status: 400, code: "BAD_REQUEST"} = error} =
               Documenso.request("/envelope/delete", method: :post, json: %{})

      assert Exception.message(error) ==
               "Input validation failed (400 BAD_REQUEST)\n  * envelopeId: Required"
    end

    test "reads the error code nested under data" do
      Req.Test.stub(Documenso, fn conn ->
        conn
        |> Plug.Conn.put_status(401)
        |> Req.Test.json(%{
          "message" => "Invalid token",
          "code" => "INTERNAL_SERVER_ERROR",
          "data" => %{"code" => "UNAUTHORIZED", "httpStatus" => 401}
        })
      end)

      assert_raise Documenso.Error, "Invalid token (401 UNAUTHORIZED)", fn ->
        Documenso.request!("/envelope")
      end
    end

    test "retries rate limited POSTs, but no other failed POSTs" do
      Req.Test.expect(Documenso, fn conn -> Plug.Conn.send_resp(conn, 429, "") end)
      Req.Test.expect(Documenso, &Req.Test.json(&1, %{"success" => true}))

      assert {:ok, %{"success" => true}} = Documenso.Envelopes.delete("envelope_abc123")

      Req.Test.expect(Documenso, fn conn -> Plug.Conn.send_resp(conn, 500, "") end)

      assert {:error, %Documenso.Error{status: 500}} =
               Documenso.Envelopes.delete("envelope_abc123")

      Req.Test.verify!()
    end

    test "points users of the removed base_url config to instance_url" do
      Application.put_env(:documenso_ex, :base_url, "https://sign.example.com/api/v1")
      on_exit(fn -> Application.delete_env(:documenso_ex, :base_url) end)

      assert_raise ArgumentError, ~r/replaced by `:instance_url`/, fn ->
        Documenso.request("/envelope")
      end
    end
  end
end
