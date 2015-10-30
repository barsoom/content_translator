defmodule ContentTranslator.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use MyApp.Web, :controller
      use MyApp.Web, :view

  Keep the definitions in this module short and clean,
  mostly focused on imports, uses and aliases.
  """

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import URL helpers from the router
      import ContentTranslator.Router.Helpers

      # Import all HTML functions (forms, tags, etc)
      use Phoenix.HTML
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Import URL helpers from the router
      import ContentTranslator.Router.Helpers
    end
  end

  def api_controller do
    quote do
      use Phoenix.Controller

      plug :authenticate

      defp authenticate(conn, _options) do
        if conn.params["token"] == Config.auth_token do
          conn
        else
          conn |> deny_and_halt
        end
      end

      defp deny_and_halt(conn) do
        conn |> send_resp(403, "Denied") |> halt
      end
    end
  end

  def model do
    quote do
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
