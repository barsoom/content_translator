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

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      alias ContentTranslator.Router.Helpers, as: Routes
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias ContentTranslator.Router.Helpers, as: Routes
    end
  end

  def api_controller do
    quote do
      use Phoenix.Controller

      plug :authenticate

      defp authenticate(conn, _options) do
        if conn.params["token"] == Config.auth_token() do
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

  def router do
    quote do
      use Phoenix.Router
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
