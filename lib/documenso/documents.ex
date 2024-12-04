defmodule Documenso.Documents do
  import Documenso.Api

  @doc """
    List all documents. Return an error tuple if the request fails.
  """
  def list() do
    with {:ok, %Req.Response{status: 200, body: body}} <- request("/documents") do
      {:ok, body["documents"]}
    end
  end

  @doc """
    List all documents. Raise an exception if the request fails.
  """
  def list!() do
    request!("/documents").body["documents"]
  end

  @doc """
    Get a document by ID. Return an error tuple if the request fails.
  """
  def get(id) do
    "/documents/#{id}"
    |> request()
  end

  @doc """
    Get a document by ID. Raise an exception if the request fails.
  """
  def get!(id) do
    "/documents/#{id}"
    |> request!()
  end

  @doc """
    Create a document. Return an error tuple if the request fails.
  """
  def create(attrs) do
    "/documents"
    |> request(method: :post, json: attrs)
  end

  @doc """
    Create a document. Raise an exception if the request fails.
  """
  def create!(attrs) do
    "/documents"
    |> request!(method: :post, json: attrs)
  end

  @doc """
    Create fields for a document. Return an error tuple if the request fails.
  """
  def create_fields(id, attrs) do
    "/documents/#{id}/fields"
    |> request(method: :post, json: attrs)
  end

  @doc """
    Create fields for a document. Raise an exception if the request fails.
  """
  def create_fields!(id, attrs) do
    "/documents/#{id}/fields"
    |> request!(method: :post, json: attrs)
  end

  @doc """
    Send a document. Return an error tuple if the request fails.
  """
  def send(id) do
    request("/documents/#{id}/send", method: :post)
  end

  @doc """
    Send a document. Raise an exception if the request fails.
  """
  def send_without_emails(id) do
    request("/documents/#{id}/send", method: :post, json: %{sendEmails: false})
  end

  @doc """
    Upload a document file. Use this function with the upload url returned by create/1 or create!/1.
    Return an error tuple if the request fails.
  """
  def upload_document(url, file, type \\ :binary)

  def upload_document(url, file, :path) do
    file =
      File.read!(file) |> Base.encode64()

    Req.put(url, form: file)
  end

  def upload_document(url, file, :binary) do
    Req.put(url, body: file)
  end

  @doc """
    Create and upload a document in one step. Return an error tuple if the request fails.

    ## Example
    >  Documenso.Documents.create_and_upload(%{name: "My Document"}, "path/to/file.pdf")
  """
  def create_and_upload(attrs, file) do
    with {:ok, %Req.Response{status: 200, body: body}} <- create(attrs),
         {:ok, %Req.Response{status: 200, body: _}} <- upload_document(body["uploadUrl"], file) do
      {:ok, body}
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Get the download url the final document. Return an error tuple if the request fails.

  ## Example
  > Documenso.Documents.download_url(123456)
  > {:ok, %{downloadUrl: "https://documenso.com/download/123456"}}
  """
  def download_url(id) do
    "/documents/#{id}/download"
    |> request()
  end
end
