# Application config
#
# Based on environment specific config in config/*.exs.
#
# Ex: Config.redis_connection_string

defmodule Config do
  # There is probably a better way to use the config files
  [{_endpoint, app_config}] = Application.get_all_env(:content_translator)

  Enum.each(app_config, fn {key, value} ->
    def unquote(key)() do
      unquote(value)
    end
  end)
end
