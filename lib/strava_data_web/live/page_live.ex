defmodule StravaDataWeb.PageLive do
  use StravaDataWeb, :live_view

  alias StravaData.Athletes

  @impl true
  def mount(_params, %{"token" => token}, socket) do
    {:ok, id} =
      Phoenix.Token.verify(StravaDataWeb.Endpoint, "athlete auth", token, max_age: :infinity)

    Phoenix.PubSub.subscribe(StravaData.PubSub, "athlete:#{id}")

    athlete = Athletes.get_athlete(id)
    activities = Athletes.get_activities_for(athlete)

    socket =
      socket
      |> assign(:athlete, athlete)
      |> assign(:activities, activities)

    {:ok, socket}
  end

  @impl true
  def handle_event("gather", _params, socket) do
    socket = assign(socket, :activities, [])
    Athletes.start_gather_athlete_data(socket.assigns.athlete)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:refresh_athlete_activities, error: false}, %{assigns: assigns} = socket) do
    activities = Athletes.get_activities_for(assigns.athlete)

    socket =
      socket
      |> assign(:activities, activities)

    {:noreply, assign(socket, :activities, activities)}
  end

  def handle_info({:refresh_athlete_activities, error: true}, %{assigns: assigns} = socket) do
    activities = Athletes.get_activities_for(assigns.athlete)

    socket =
      socket
      |> assign(:activities, activities)
      |> put_flash(:info, "There were some errors while gathering your data.")

    {:noreply, assign(socket, :activities, activities)}
  end
end
