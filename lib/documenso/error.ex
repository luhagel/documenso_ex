defmodule Documenso.Error do
  @moduledoc """
  A non-2xx response from the Documenso API.

  `code` is the API's error code, such as `"NOT_FOUND"`, `"UNAUTHORIZED"`, `"LIMIT_EXCEEDED"`
  or `"TOO_MANY_REQUESTS"`. `issues` lists what was wrong with a rejected request body.
  The full `Req.Response` is kept in `response`.
  """

  defexception [:status, :code, :message, :response, issues: []]

  @type t :: %__MODULE__{
          status: pos_integer(),
          code: String.t() | nil,
          message: String.t(),
          issues: [map()],
          response: Req.Response.t()
        }

  @impl true
  def exception(%Req.Response{status: status, body: body} = response) do
    body = if is_map(body), do: body, else: %{}

    %__MODULE__{
      status: status,
      code: code(body),
      message: body["message"] || body["error"] || "HTTP #{status}",
      issues: body["issues"] || [],
      response: response
    }
  end

  @impl true
  def message(%__MODULE__{status: status, code: code, message: message, issues: issues}) do
    details = Enum.map_join(issues, "", &"\n  * #{issue(&1)}")
    "#{message} (#{Enum.join(Enum.reject([status, code], &is_nil/1), " ")})#{details}"
  end

  defp issue(%{"path" => [_ | _] = path, "message" => message}),
    do: "#{Enum.join(path, ".")}: #{message}"

  defp issue(%{"message" => message}), do: message

  # Some errors report "INTERNAL_SERVER_ERROR" at the top level and the real code under "data".
  defp code(%{"data" => %{"code" => code}}), do: code
  defp code(%{"code" => code}), do: code
  defp code(_body), do: nil
end
