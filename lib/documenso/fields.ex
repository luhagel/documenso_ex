defmodule Documenso.Fields do
  @moduledoc """
  Fields are the places on an envelope's PDFs where recipients sign, date or fill in.
  They can only be changed while the envelope is a draft.
  """

  import Documenso.Api, only: [request: 2, unwrap!: 1]

  @doc """
  Adds fields to a draft envelope. Calls `POST /envelope/field/create-many`.

  Place a field by position, in percent of the page:

      %{recipientId: 1, type: "SIGNATURE", page: 1, positionX: 70, positionY: 85, width: 20, height: 5}

  or at a text marker in the PDF:

      %{recipientId: 1, type: "SIGNATURE", placeholder: "{{signature}}"}

  For envelopes with several PDFs, `envelopeItemId` picks the one a field goes on.
  """
  @spec create_many(String.t(), [map()], Keyword.t()) :: {:ok, map()} | {:error, Exception.t()}
  def create_many(envelope_id, fields, options \\ []) when is_list(fields) do
    request(
      "/envelope/field/create-many",
      [method: :post, json: %{envelopeId: envelope_id, data: fields}] ++ options
    )
  end

  @doc "Same as `create_many/3`, but returns the body or raises."
  def create_many!(envelope_id, fields, options \\ []),
    do: envelope_id |> create_many(fields, options) |> unwrap!()
end
