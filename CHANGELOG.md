# Changelog

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
