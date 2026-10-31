defmodule Documenso.Webhook do
  @moduledoc """
  Helpers for receiving Documenso webhooks.

  Documenso POSTs JSON like this to your endpoint:

      %{
        "event" => "DOCUMENT_COMPLETED",
        "payload" => %{
          "id" => 123,
          "envelopeId" => "envelope_abc123",
          "externalId" => "acme:contract:42",
          "title" => "Service agreement",
          "status" => "COMPLETED",
          "recipients" => [
            %{"id" => 1, "envelopeId" => "envelope_abc123", "email" => "ada@example.com",
              "token" => "...", "role" => "SIGNER", "signingStatus" => "SIGNED", ...}
          ],
          ...
        },
        "createdAt" => "2026-10-27T08:00:00.000Z",
        "webhookEndpoint" => "https://example.com/webhooks/documenso"
      }

  `"envelopeId"` is the ID to use. `"id"` is the numeric ID of API v1.
  `Documenso.Recipients.signing_url/2` turns a recipient's `"token"` into a signing link.

  ## Events

  | Event | Fires when |
  | --- | --- |
  | `DOCUMENT_CREATED` | A document is created, also from a template |
  | `DOCUMENT_SENT` | A document is distributed and becomes `PENDING` |
  | `DOCUMENT_OPENED` | A recipient opens it for the first time |
  | `DOCUMENT_SIGNED` | Any recipient signs |
  | `DOCUMENT_RECIPIENT_COMPLETED` | A recipient finishes signing, approving or viewing |
  | `DOCUMENT_COMPLETED` | Every recipient is done |
  | `DOCUMENT_REJECTED` | A recipient declines, see `"rejectionReason"` |
  | `DOCUMENT_CANCELLED` | A pending document is cancelled or deleted |
  | `RECIPIENT_EXPIRED` | A recipient's deadline passes |
  | `DOCUMENT_REMINDER_SENT` | Documenso sends a reminder |
  | `TEMPLATE_CREATED`, `TEMPLATE_UPDATED`, `TEMPLATE_DELETED` | A template changes |
  | `TEMPLATE_USED` | A document is created from a template |

  ## Handling

    * Check the `X-Documenso-Secret` header with `Documenso.Webhook.Plug` or `verify/2`.
      Documenso sends the secret itself, not a signature.
    * Respond with a 2xx within 10 seconds. Move slow work, like sending emails, to a job.
    * Deliveries can repeat and carry no delivery ID. Make handlers idempotent, for example
      with a unique job per event, envelope ID and recipient ID.
    * Webhooks are set up per team in Documenso's settings. There is no API for them.
  """

  @doc """
  Checks a received `X-Documenso-Secret` header against the expected secret in constant time.

  The expected secret defaults to `config :documenso_ex, :webhook_secret`. Without one,
  every request is rejected, since an empty secret would let anyone in.
  """
  @spec verify(String.t() | nil, String.t() | nil) :: boolean()
  def verify(received, expected \\ Application.get_env(:documenso_ex, :webhook_secret))

  def verify(received, expected)
      when is_binary(received) and is_binary(expected) and expected != "",
      do: :crypto.hash_equals(:crypto.hash(:sha256, received), :crypto.hash(:sha256, expected))

  def verify(_received, _expected), do: false
end
