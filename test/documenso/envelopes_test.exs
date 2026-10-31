defmodule Documenso.EnvelopesTest do
  use ExUnit.Case, async: true

  alias Documenso.Envelopes

  test "list/2 sends params as the query" do
    Req.Test.stub(Documenso, fn conn ->
      assert {conn.method, conn.request_path} == {"GET", "/api/v2/envelope"}
      assert conn.query_string == "status=PENDING"
      Req.Test.json(conn, %{"data" => [], "totalPages" => 0})
    end)

    assert {:ok, %{"data" => []}} = Envelopes.list(%{status: "PENDING"})
  end

  test "stream/2 walks every page" do
    Req.Test.stub(Documenso, fn conn ->
      page = String.to_integer(Plug.Conn.fetch_query_params(conn).query_params["page"])
      Req.Test.json(conn, %{"data" => [%{"id" => "envelope_#{page}"}], "totalPages" => 3})
    end)

    assert Envelopes.stream() |> Enum.map(& &1["id"]) ==
             ["envelope_1", "envelope_2", "envelope_3"]
  end

  test "get/2 puts the ID in the path" do
    Req.Test.stub(Documenso, fn conn ->
      assert conn.request_path == "/api/v2/envelope/envelope_abc123"
      Req.Test.json(conn, %{"id" => "envelope_abc123"})
    end)

    assert %{"id" => "envelope_abc123"} = Envelopes.get!("envelope_abc123")
  end

  test "get_many/2 wraps the IDs" do
    Req.Test.stub(Documenso, fn conn ->
      assert conn.body_params == %{"ids" => %{"type" => "documentId", "ids" => [123]}}
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, %{"data" => []}} = Envelopes.get_many(%{type: "documentId", ids: [123]})
  end

  test "create/3 uploads the payload and files as multipart" do
    Req.Test.stub(Documenso, fn conn ->
      %{"payload" => payload, "files" => file} = conn.body_params

      assert Jason.decode!(payload) == %{"type" => "DOCUMENT", "title" => "Contract"}
      assert {file.filename, file.content_type} == {"contract.pdf", "application/pdf"}
      assert File.read!(file.path) == "%PDF-1.7"
      Req.Test.json(conn, %{"id" => "envelope_abc123"})
    end)

    assert {:ok, %{"id" => "envelope_abc123"}} =
             Envelopes.create(
               %{type: "DOCUMENT", title: "Contract"},
               {"%PDF-1.7", filename: "contract.pdf"}
             )
  end

  test "distribute_without_emails/3 turns off every email, but keeps the caller's meta" do
    Req.Test.stub(Documenso, fn conn ->
      assert %{"envelopeId" => "envelope_abc123", "meta" => meta} = conn.body_params
      assert meta["distributionMethod"] == "NONE"
      assert meta["redirectUrl"] == "https://example.com/done"
      assert meta["emailSettings"] |> Map.values() |> Enum.uniq() == [false]

      Req.Test.json(conn, %{
        "recipients" => [%{"signingUrl" => "https://app.documenso.com/sign/abc"}]
      })
    end)

    assert {:ok, %{"recipients" => [_recipient]}} =
             Envelopes.distribute_without_emails("envelope_abc123", %{
               meta: %{redirectUrl: "https://example.com/done"}
             })
  end

  test "download/3 returns the PDF" do
    Req.Test.stub(Documenso, fn conn ->
      assert conn.request_path == "/api/v2/envelope/item/envelope_item_1/download"
      assert conn.query_string == "version=original"

      conn
      |> Plug.Conn.put_resp_content_type("application/pdf")
      |> Plug.Conn.send_resp(200, "%PDF-1.7")
    end)

    assert {:ok, "%PDF-1.7"} = Envelopes.download("envelope_item_1", %{version: "original"})
  end
end
