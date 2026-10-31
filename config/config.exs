import Config

# Tests stub every request with Req.Test, so they never get real credentials.
if config_env() != :test and File.exists?(Path.join(__DIR__, "config.secret.exs")) do
  import_config "config.secret.exs"
end

if File.exists?(Path.join(__DIR__, "#{config_env()}.exs")) do
  import_config "#{config_env()}.exs"
end
