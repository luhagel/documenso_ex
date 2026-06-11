import Config

config :documenso_ex,
  base_url: "https://documenso.example.com/api/v1",
  api_key: "test_api_key",
  req_options: [plug: {Req.Test, Documenso.Api}, retry: false]
