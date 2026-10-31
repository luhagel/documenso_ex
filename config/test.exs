import Config

config :documenso_ex,
  instance_url: "https://documenso.example.com",
  api_key: "test_api_key",
  webhook_secret: "test_webhook_secret",
  req_options: [plug: {Req.Test, Documenso}, retry_delay: 0, retry_log_level: false]
