# This is a pretty hacky script! Feel free to improve it. E.g. run it in production instead so we can use ENVs directly etc.

[locale, model_key] =
  case System.argv() do
    [loc, mod] -> [loc, mod]
    [loc] -> [loc, nil]
    _ ->
      IO.warn "Please provide arguments"
      System.halt(1)
  end

{heroku_config, 0} = System.cmd("heroku", [ "config:get", "-a", "auctionet-content-translator", "WTI_PROJECT_TOKEN", "CLIENT_APP_WEBHOOK_URL" ])
[wti_project_token, client_app_webhook_url] = String.split(heroku_config, "\n", trim: true)

# Figure out max number of pages, in a simple but non-optimized way.

# https://webtranslateit.com/en/docs/api/string
response = HTTPotion.get "https://webtranslateit.com/api/projects/#{wti_project_token}/strings.json?locale=#{locale}"

link_header = Keyword.fetch!(response.headers, :Link)
[_, last_page_number] = Regex.run(~r{page=(\d+)>; rel="last"}, link_header)
last_page_number = String.to_integer(last_page_number)

for page <- 1..last_page_number do
  IO.puts "Getting page #{page}…"

  # Get translations from WTI.

  # https://webtranslateit.com/en/docs/api/string
  response = HTTPotion.get "https://webtranslateit.com/api/projects/#{wti_project_token}/strings.json?locale=#{locale}&page=#{page}"
  json = Poison.decode!(response.body)

  keys_to_translations = json |> Enum.map(fn
     %{"key" => key, "translations" => %{"text" => text}} -> {key, text}
     %{"key" => key, "translations" => nil} -> {key, ""}
  end) |> Enum.filter(fn {_, ""} -> false; _ -> true; end)

  # Send to the client app.

  for {key, translation} <- keys_to_translations do
    if !model_key || String.match?(key, ~r{\A#{Regex.escape(model_key)}_\d+:}) do
      IO.puts "Updating #{key}…"

      body = "payload=#{URI.encode_www_form(JSON.encode(%{locale: locale, key: key, value: translation}))}"
      %{status_code: 200} = HTTPotion.post client_app_webhook_url, [body: body]

      # Throttle a bit so we don't overload the client server.
      Process.sleep(100)  # ms
    end
  end
end
