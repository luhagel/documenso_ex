defmodule Documenso.Documents do
  import Documenso.Api

  @doc """
    List all documents. Return an error tuple if the request fails.
  """
  def list() do
    case request("/documents") do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body["documents"]}
      {:ok, %Req.Response{} = resp} -> {:error, resp}
      {:error, _} = err -> err
    end
  end

  @doc """
    List all documents. Raise an exception if the request fails.
  """
  def list!() do
    case request!("/documents") do
      %Req.Response{status: 200, body: body} ->
        body["documents"]

      %Req.Response{} = resp ->
        raise "Documenso.Documents.list! failed: #{inspect(resp)}"
    end
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
  def send(id, opts \\ %{}) do
    request("/documents/#{id}/send", method: :post, json: opts)
  end

  @doc """
    Send a document and prevent all emails from being sent out.
    Return an error tuple if the request fails.
  """
  def send_without_emails(id) do
    request("/documents/#{id}/send",
      method: :post,
      json: %{sendEmails: false, sendCompletionEmails: false}
    )
  end

  @doc """
    Delete a document.
    Raise an exception if the request fails.
  """
  def delete!(id) do
    request!("/documents/#{id}", method: :delete)
  end

  @doc """
    Delete a document.
    Return an error tuple if the request fails.
  """
  def delete(id) do
    request("/documents/#{id}", method: :delete)
  end

  @doc """
    Upload a document file. Use this function with the upload url returned by create/1 or create!/1.
    Return an error tuple if the request fails.
  """
  def upload_document(url, file, type \\ :binary)

  def upload_document(url, file, :path) do
    encoded = file |> File.read!() |> Base.encode64()
    Req.put(url, [form: encoded] ++ Documenso.Api.default_options())
  end

  def upload_document(url, file, :binary) do
    Req.put(url, [body: file] ++ Documenso.Api.default_options())
  end

  @doc """
    Create and upload a document in one step. Return an error tuple if the request fails.

    ## Example
    >  Documenso.Documents.create_and_upload(%{name: "My Document"}, "path/to/file.pdf")
  """
  def create_and_upload(attrs, file) do
    with {:ok, %Req.Response{status: 200, body: body}} <- create(attrs),
         {:ok, %Req.Response{status: 200}} <- upload_document(body["uploadUrl"], file) do
      {:ok, body}
    else
      {:ok, %Req.Response{} = resp} -> {:error, resp}
      {:error, _} = err -> err
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
