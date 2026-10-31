# Documenso

An Elixir client for the [Documenso](https://documenso.com) API v2, with webhook helpers.

## Installation

```elixir
def deps do
  [
    {:documenso_ex, "~> 1.0"}
  ]
end
```

## Configuration

```elixir
config :documenso_ex,
  api_key: "api_...",
  # Only for self-hosted instances. Defaults to https://app.documenso.com
  instance_url: "https://sign.example.com",
  # Only for receiving webhooks
  webhook_secret: "..."
```

API keys belong to one Documenso team. To work with several teams, pass `api_key:` to any function.

## Usage

Create an envelope with its recipients and fields, then send it:

```elixir
alias Documenso.Envelopes

{:ok, %{"id" => id}} =
  Envelopes.create(
    %{
      type: "DOCUMENT",
      title: "Service agreement",
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

{:ok, %{"recipients" => recipients}} = Envelopes.distribute(id)
```

To send the emails yourself, use `Envelopes.distribute_without_emails/3` and deliver each recipient's `"signingUrl"`.

Read envelopes:

```elixir
{:ok, envelope} = Envelopes.get(id)
{:ok, pdf} = Envelopes.download(hd(envelope["envelopeItems"])["id"])

Envelopes.stream(%{status: "COMPLETED"}) |> Enum.take(250)
```

### Conventions

- Modules and functions mirror the API: `POST /envelope/distribute` is `Documenso.Envelopes.distribute`. Call any other endpoint with `Documenso.request/2`.
- Maps are API data, sent as they are in the camelCase of the [API reference](https://openapi.documenso.com). Keyword lists are options: `api_key:`, `instance_url:` and anything `Req` accepts.
- Functions return `{:ok, body}` or `{:error, exception}`. API errors are a `Documenso.Error` with `status`, `code`, `message` and `issues`. The `!` variants raise instead.
- Envelope IDs are strings like `"envelope_abc123"`. Recipient and field IDs are integers.

## Webhooks

```elixir
# router.ex
pipeline :documenso_webhook do
  plug :accepts, ["json"]
  plug Documenso.Webhook.Plug
end

scope "/webhooks" do
  pipe_through :documenso_webhook
  post "/documenso", MyAppWeb.DocumensoWebhookController, :create
end

# documenso_webhook_controller.ex
def create(conn, %{"event" => "DOCUMENT_COMPLETED", "payload" => payload}) do
  MyApp.Contracts.completed(payload["envelopeId"])
  send_resp(conn, 200, "")
end

def create(conn, _params), do: send_resp(conn, 200, "")
```

`Documenso.Webhook` lists every event and how to handle deliveries. `Documenso.Recipients.signing_url/2` builds a signing link from the recipient tokens in webhook payloads.

## Testing

Route requests to `Req.Test` in your test config:

```elixir
config :documenso_ex,
  api_key: "test",
  req_options: [plug: {Req.Test, Documenso}]
```

```elixir
Req.Test.stub(Documenso, &Req.Test.json(&1, %{"id" => "envelope_abc123"}))
```

## Upgrading from 0.4

0.4 used API v1, which Documenso removes on 1 March 2027.

| 0.4 | 1.0 |
| --- | --- |
| `config :documenso_ex, base_url: ".../api/v1"` | `config :documenso_ex, instance_url: "..."` |
| `Documents.list/0` | `Envelopes.list/2`, `Envelopes.stream/2` |
| `Documents.get/1` | `Envelopes.get/2` |
| `Documents.create/1`, `upload_document/3`, `create_and_upload/2` | `Envelopes.create/3` |
| `Documents.create_fields/2` | `Fields.create_many/3`, or fields inside `create/3` |
| `Documents.send/2` | `Envelopes.distribute/3` |
| `Documents.send_without_emails/1` | `Envelopes.distribute_without_emails/3` |
| `Documents.delete/1` | `Envelopes.delete/2` |
| `Documents.download_url/1` | `Envelopes.download/3`, which returns the PDF |

Document IDs from v1 are numbers. To find their envelopes, call `Envelopes.get_many(%{type: "documentId", ids: ids})` with up to 20 IDs at a time.

## Local development

Put a key in `config/config.secret.exs`, which git ignores:

```elixir
import Config

config :documenso_ex,
  api_key: "api_123456789"
```
