defmodule Documenso.FieldsTest do
  use ExUnit.Case, async: true

  test "create_many/3 sends the fields with the envelope ID" do
    field = %{"recipientId" => 1, "type" => "SIGNATURE", "placeholder" => "{{signature}}"}

    Req.Test.stub(Documenso, fn conn ->
      assert {conn.method, conn.request_path} == {"POST", "/api/v2/envelope/field/create-many"}
      assert conn.body_params == %{"envelopeId" => "envelope_abc123", "data" => [field]}
      Req.Test.json(conn, %{"data" => [Map.put(field, "id", 7)]})
    end)

    assert {:ok, %{"data" => [%{"id" => 7}]}} =
             Documenso.Fields.create_many("envelope_abc123", [field])
  end
end
