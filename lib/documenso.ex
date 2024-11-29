defmodule Documenso do
  @moduledoc """
  Documentation for `Documenso`.
  """

  def new(options \\ []), do: Documenso.Api.new(options)

  def request(url, options \\ []), do: Documenso.Api.request(url, options)
  def request!(url, options \\ []), do: Documenso.Api.request!(url, options)
end
