defmodule Documenso.Documents do
  import Documenso.Api

  def list() do
    with {:ok, %Req.Response{status: 200, body: body}} <- request("/documents") do
      {:ok, body["documents"]}
    end
  end

  def list!() do
    request!("/documents").body["documents"]
  end

  def get(id) do
    "/documents/#{id}"
    |> request()
  end

  def get!(id) do
    "/documents/#{id}"
    |> request!()
  end

  def create(attrs) do
    "/documents"
    |> request(method: :post, json: attrs)
  end

  def create!(attrs) do
    "/documents"
    |> request!(method: :post, json: attrs)
  end

  def create_fields(id, attrs) do
    "/documents/#{id}/fields"
    |> request(method: :post, json: attrs)
  end

  def create_fields!(id, attrs) do
    "/documents/#{id}/fields"
    |> request!(method: :post, json: attrs)
  end

  def send(id) do
    request("/documents/#{id}/send", method: :post)
  end

  def send_without_emails(id) do
    request("/documents/#{id}/send", method: :post, json: %{sendEmails: false})
  end

  def upload_document(url, file) do
    file =
      if Regex.match?(~r"^(.+)\/([^\/]+)$", file) do
        File.read!(file) |> Base.encode64()
      else
        file
      end

    Req.put(url, form: file)
  end
end
