# Application config
#
# Based on environment specific config in config/*.exs.
#
# Ex: Config.redis_connection_string

defmodule Config do
  # There is probably a better way to use the config files
  app_config = Application.get_all_env(:content_translator) |> hd |> Tuple.to_list |> tl |> hd

  Enum.each app_config, fn ({ key, value }) ->
    def unquote(key)() do
      unquote(value)
    end
  end
end
