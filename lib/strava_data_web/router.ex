defmodule StravaDataWeb.Router do
  use StravaDataWeb, :router

  alias StravaDataWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {StravaDataWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StravaDataWeb do
    pipe_through([:browser, Plugs.EnsureToken])

    live "/", PageLive, :index
  end

  scope "/signup", StravaDataWeb do
    pipe_through([:browser, Plugs.EnsureNoToken])

    live "/", SignUpLive, :index
  end

  scope "/api", StravaDataWeb do
    pipe_through(:api)

    scope path: "/auth" do
      get "/", AuthController, :auth
      get "/callback", AuthController, :callback
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", StravaDataWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: StravaDataWeb.Telemetry
    end
  end

  def ensure_no_athelete_token(conn, _opts) do
    case get_session(conn, :token) do
      token when is_binary(token) ->
        conn

      _ ->
        conn
        |> Phoenix.Controller.redirect(to: "/signup")
        |> halt()
    end
  end
end
