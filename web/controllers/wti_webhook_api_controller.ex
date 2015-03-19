defmodule ContentTranslator.WtiWebhookApiController do
  use ContentTranslator.Web, :controller

  plug :action

  # Example payload
  # {"project_id":1,"string_id":456,"user_id":10,"locale":"en","file_id":null,"api_url":"URL","translation":{"id":123,"locale":"en","text":"English text","status":"status_unproofread","created_at":"2015-03-19T12:55:52Z","updated_at":"2015-03-19T12:59:56Z","version":6,"string":{"id":456,"key":"test.segment","plural":false,"type":"String","dev_comment":"","status":"Current"}}}
  def create(conn, %{ "format" => "json", "payload" => payload }) do
    IO.puts payload
    text conn, "ok"
  end
end