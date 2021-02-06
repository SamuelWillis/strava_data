defmodule StravaDataWeb.ConnCase do
  alias StravaData.Factory

  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use StravaDataWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import StravaDataWeb.ConnCase

      alias StravaDataWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint StravaDataWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(StravaData.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(StravaData.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def insert_athlete_and_set_session_token(%{conn: conn}) do
    athlete = Factory.insert(:athlete_with_tokens)

    token = Phoenix.Token.sign(StravaDataWeb.Endpoint, "athlete auth", athlete.id)

    conn = Phoenix.ConnTest.init_test_session(conn, %{token: token})

    %{conn: conn, athlete: athlete}
  end
end
