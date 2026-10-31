# Changelog

## 1.0.0 (unreleased)

Switches to the Documenso API v2, since v1 is removed on 1 March 2027. See "Upgrading from 0.4" in the README.

- replace `Documenso.Documents` with `Documenso.Envelopes` and `Documenso.Fields`
- replace the `base_url` config with `instance_url`, without the `/api/v1` suffix
- return `{:ok, body}` or `{:error, %Documenso.Error{}}` from every function, and raise `Documenso.Error` from `!` variants
- accept `api_key:` and `instance_url:` on every call, to work with several teams
- add `Documenso.Envelopes.stream/2`, which pages through all envelopes
- retry rate limited requests, including POSTs
- add `Documenso.Webhook.verify/2`, `Documenso.Webhook.Plug` and `Documenso.Recipients.signing_url/2`
- ship `usage-rules.md` for coding agents
- update dependencies and require `req >= 0.7.5`. `plug ~> 1.20` is optional and only needed for `Documenso.Webhook.Plug`

## 0.4.2
- update req and relax version requirements

## 0.4.1
- make base_url configurable at runtime, not just compiletime

## 0.4.0
- support overriding the base url by defining `config :documenso_ex, base_url: "https://documenso.example.com/api/v1"`
- update dependencies

## 0.3.0

- add a document `delete/1` and `delete!` function
- fix an issue with the `send_without_emails/2` function not actually preventing completion emails

## 0.2.3

- update the `send_without_emails/1` function to also pass the new `sendCompletionEmail` flag
- enable passing custom options to the `send/2` function

## 0.2.2

- add a `download_url/1` function to donwload the finished document

## 0.2.1

- allow passing either a path or binary to `upload_document/2`

## 0.2.0

- add a `create_and_upload/2` function to create a document and upload it to the returned url in one go
