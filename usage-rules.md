# documenso_ex usage rules

A client for the Documenso API v2. The API reference is https://openapi.documenso.com.

- Modules mirror the API. `POST /envelope/distribute` is `Documenso.Envelopes.distribute`. Call endpoints without a wrapper through `Documenso.request/2`, with a path relative to `/api/v2`.
- Documents and templates are both envelopes, told apart by `type: "DOCUMENT" | "TEMPLATE"`. Never call the deprecated `/document/*` or `/template/*` endpoints. They are removed on 1 March 2027.
- Maps are API data, with the camelCase keys from the API reference. Keyword lists are options: `api_key:`, `instance_url:` and `Req` options. To pass only options, give an empty map first: `Envelopes.list(%{}, api_key: key)`.
- Required IDs are positional: `Envelopes.distribute(envelope_id)`, never `%{envelopeId: ...}`.
- Every function returns `{:ok, body}` with the decoded JSON body (string keys), or `{:error, exception}`. Match API errors on `%Documenso.Error{code: "NOT_FOUND"}`, not on the message. `!` variants raise.
- Envelope and envelope item IDs are strings (`"envelope_..."`). Recipient and field IDs are integers. Numeric document IDs from API v1 map to envelopes through `Envelopes.get_many(%{type: "documentId", ids: ids})`, 20 at a time.
- Create an envelope with its recipients and fields in one `Envelopes.create/3` call, then `distribute/3`. Recipients and fields can only change while the envelope is `DRAFT`.
- Field positions are percentages of the page (0 to 100), not points.
- `Envelopes.download/3` takes an envelope item ID from `get/2`'s `"envelopeItems"` and returns the PDF binary.
- Use `distribute_without_emails/3` when the app sends its own emails. Deliver the returned `"signingUrl"`s, or build them from webhook tokens with `Documenso.Recipients.signing_url/2`.
- Protect webhook routes with `Documenso.Webhook.Plug`. Match events as strings (`"DOCUMENT_COMPLETED"`), answer within 10 seconds, and make handlers idempotent, since deliveries repeat.
- In tests, set `req_options: [plug: {Req.Test, Documenso}]` and stub with `Req.Test.stub(Documenso, ...)`.
