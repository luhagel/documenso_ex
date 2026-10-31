defmodule Documenso.Envelopes do
  @moduledoc """
  Envelopes are Documenso's documents and templates. An envelope holds one or more PDFs,
  called items, plus the recipients and fields placed on them.

  A typical flow creates an envelope with its recipients and fields in one call, then
  distributes it:

      {:ok, %{"id" => id}} = Documenso.Envelopes.create(attrs, "contract.pdf")
      {:ok, %{"recipients" => recipients}} = Documenso.Envelopes.distribute(id)

  See the [API reference](https://openapi.documenso.com) for every attribute.
  """

  import Documenso.Api, only: [request: 2, unwrap!: 1]

  @typedoc "A path, or `{content, filename: \"contract.pdf\"}` for a PDF already in memory."
  @type file :: Path.t() | {iodata(), Keyword.t()}

  @type result :: {:ok, map()} | {:error, Exception.t()}

  @silent_meta %{
    distributionMethod: "NONE",
    emailSettings: %{
      recipientSigningRequest: false,
      recipientRemoved: false,
      recipientSigned: false,
      documentPending: false,
      documentCompleted: false,
      documentDeleted: false,
      ownerDocumentCompleted: false,
      ownerRecipientExpired: false,
      ownerDocumentCreated: false
    }
  }

  @doc """
  Lists one page of envelopes. Calls `GET /envelope`.

  `params` are query parameters such as `type`, `status`, `page` and `perPage` (at most 100).
  The body holds `"data"`, `"count"`, `"currentPage"`, `"perPage"` and `"totalPages"`.

      {:ok, %{"data" => envelopes}} = Documenso.Envelopes.list(%{status: "PENDING"})
  """
  @spec list(map(), Keyword.t()) :: result()
  def list(params \\ %{}, options \\ []) when is_map(params),
    do: request("/envelope", [params: params] ++ options)

  @doc "Same as `list/2`, but returns the body or raises."
  def list!(params \\ %{}, options \\ []), do: params |> list(options) |> unwrap!()

  @doc """
  Streams every envelope matching `params`, fetching pages of 100 as it goes.
  Raises if a page can't be fetched.

      Documenso.Envelopes.stream(%{status: "COMPLETED"}) |> Enum.take(250)
  """
  @spec stream(map(), Keyword.t()) :: Enumerable.t(map())
  def stream(params \\ %{}, options \\ []) when is_map(params) do
    params = Map.put_new(params, :perPage, 100)

    Stream.resource(
      fn -> 1 end,
      fn
        nil ->
          {:halt, nil}

        page ->
          %{"data" => data, "totalPages" => total} = list!(Map.put(params, :page, page), options)
          {data, if(page < total, do: page + 1)}
      end,
      fn _page -> :ok end
    )
  end

  @doc """
  Gets an envelope with its recipients, fields and items. Calls `GET /envelope/{envelopeId}`.
  """
  @spec get(String.t(), Keyword.t()) :: result()
  def get(id, options \\ []), do: request("/envelope/:id", [path_params: [id: id]] ++ options)

  @doc "Same as `get/2`, but returns the body or raises."
  def get!(id, options \\ []), do: id |> get(options) |> unwrap!()

  @doc """
  Gets up to 20 envelopes at once. Calls `POST /envelope/get-many`.

  `ids` is `%{type: "envelopeId", ids: [...]}`. With `type: "documentId"` or `"templateId"`
  it takes the numeric IDs of API v1, which converts stored v1 IDs to envelope IDs.
  Envelopes you can't access are left out instead of failing the call.

      {:ok, %{"data" => envelopes}} =
        Documenso.Envelopes.get_many(%{type: "documentId", ids: [123, 124]})
  """
  @spec get_many(map(), Keyword.t()) :: result()
  def get_many(ids, options \\ []) when is_map(ids),
    do: request("/envelope/get-many", [method: :post, json: %{ids: ids}] ++ options)

  @doc "Same as `get_many/2`, but returns the body or raises."
  def get_many!(ids, options \\ []), do: ids |> get_many(options) |> unwrap!()

  @doc """
  Creates an envelope from one or more PDFs. Calls `POST /envelope/create`.

  `attrs` needs `type` (`"DOCUMENT"` or `"TEMPLATE"`) and `title`. Recipients and their
  fields can be added in the same call. Field positions are percentages of the page, and
  `identifier` is the index or filename of the PDF a field goes on. Documenso also turns
  text markers in the PDF into fields by itself.

      {:ok, %{"id" => id}} =
        Documenso.Envelopes.create(
          %{
            type: "DOCUMENT",
            title: "Service agreement",
            externalId: "acme:contract:42",
            recipients: [
              %{
                name: "Ada Lovelace",
                email: "ada@example.com",
                role: "SIGNER",
                fields: [
                  %{type: "SIGNATURE", identifier: 0, page: 1, positionX: 70, positionY: 85, width: 20, height: 5}
                ]
              }
            ]
          },
          "contract.pdf"
        )
  """
  @spec create(map(), file() | [file()], Keyword.t()) :: result()
  def create(attrs, files, options \\ []) when is_map(attrs) do
    parts =
      [payload: Jason.encode!(attrs)] ++ Enum.map(List.wrap(files), &{:files, file_part(&1)})

    request("/envelope/create", [method: :post, form_multipart: parts] ++ options)
  end

  @doc "Same as `create/3`, but returns the body or raises."
  def create!(attrs, files, options \\ []), do: attrs |> create(files, options) |> unwrap!()

  @doc """
  Sends a draft envelope to its recipients. Calls `POST /envelope/distribute`.

  `attrs` can hold `meta` overrides such as `subject`, `message` or `redirectUrl`.
  The body lists each recipient with their `"signingUrl"`.
  """
  @spec distribute(String.t(), map(), Keyword.t()) :: result()
  def distribute(id, attrs \\ %{}, options \\ []) when is_map(attrs) do
    request(
      "/envelope/distribute",
      [method: :post, json: Map.put(attrs, :envelopeId, id)] ++ options
    )
  end

  @doc "Same as `distribute/3`, but returns the body or raises."
  def distribute!(id, attrs \\ %{}, options \\ []),
    do: id |> distribute(attrs, options) |> unwrap!()

  @doc """
  Same as `distribute/3`, but Documenso sends no emails at all, neither to recipients
  nor to the owner. Deliver the `"signingUrl"` of each recipient yourself.

  Keys in `attrs.meta` win over the email settings this sets.

      {:ok, %{"recipients" => recipients}} = Documenso.Envelopes.distribute_without_emails(id)
  """
  @spec distribute_without_emails(String.t(), map(), Keyword.t()) :: result()
  def distribute_without_emails(id, attrs \\ %{}, options \\ []) when is_map(attrs) do
    attrs = Map.update(attrs, :meta, @silent_meta, &Map.merge(@silent_meta, &1))
    distribute(id, attrs, options)
  end

  @doc "Same as `distribute_without_emails/3`, but returns the body or raises."
  def distribute_without_emails!(id, attrs \\ %{}, options \\ []),
    do: id |> distribute_without_emails(attrs, options) |> unwrap!()

  @doc """
  Deletes an envelope. Completed envelopes can't be deleted. Calls `POST /envelope/delete`.
  """
  @spec delete(String.t(), Keyword.t()) :: result()
  def delete(id, options \\ []),
    do: request("/envelope/delete", [method: :post, json: %{envelopeId: id}] ++ options)

  @doc "Same as `delete/2`, but returns the body or raises."
  def delete!(id, options \\ []), do: id |> delete(options) |> unwrap!()

  @doc """
  Downloads one PDF of an envelope and returns its bytes.
  Calls `GET /envelope/item/{envelopeItemId}/download`.

  Item IDs are in the `"envelopeItems"` of `get/2`. `params` can set `version` to
  `"signed"` (the default), `"original"` or `"pending"`.

      {:ok, %{"envelopeItems" => [%{"id" => item_id}]}} = Documenso.Envelopes.get(id)
      {:ok, pdf} = Documenso.Envelopes.download(item_id)
  """
  @spec download(String.t(), map(), Keyword.t()) :: {:ok, binary()} | {:error, Exception.t()}
  def download(item_id, params \\ %{}, options \\ []) when is_map(params) do
    request(
      "/envelope/item/:id/download",
      [path_params: [id: item_id], params: params] ++ options
    )
  end

  @doc "Same as `download/3`, but returns the PDF or raises."
  def download!(item_id, params \\ %{}, options \\ []),
    do: item_id |> download(params, options) |> unwrap!()

  defp file_part(path) when is_binary(path),
    do: {File.read!(path), filename: Path.basename(path), content_type: "application/pdf"}

  defp file_part({content, options}),
    do: {content, Keyword.put_new(options, :content_type, "application/pdf")}
end
