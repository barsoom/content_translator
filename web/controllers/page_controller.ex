defmodule ContentTranslator.PageController do
  use ContentTranslator.Web, :controller

  def index(conn, _params) do
    html conn, "This is an API-only app, see the docs at <a href='https://github.com/barsoom/content_translator'>https://github.com/barsoom/content_translator</a>."
  end

  def revision(conn, _params) do
    conn |> text(System.get_env("HEROKU_SLUG_COMMIT"))
  end

  def redirect_to_translation_service(conn, params) do
    url = "https://webtranslateit.com/projects/#{project_id()}/locales/#{params["from"]}..#{params["to"]}/strings?s=#{params["query"]}"
    redirect(conn, external: url)
  end

  defp project_id, do: Config.wti_project_id
end

