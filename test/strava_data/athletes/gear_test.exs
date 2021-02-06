defmodule StravaData.Athletes.GearTest do
  use StravaData.DataCase, async: true

  alias StravaData.Athletes.Gear

  describe "changeset/2" do
    test "inserts valid attrs" do
      athlete = insert(:athlete)

      attrs = %{
        athlete_id: athlete.id,
        strava_id: "b1234",
        name: "SB150",
        primary: true
      }

      changeset = Gear.changeset(%Gear{}, attrs)

      assert changeset.valid?
    end

    test "ensures strava_id is unique" do
      athlete = insert(:athlete)

      attrs = %{
        athlete_id: athlete.id,
        strava_id: "b1234",
        name: "SB150",
        primary: true
      }

      %Gear{}
      |> Gear.changeset(attrs)
      |> Repo.insert()

      {:error, changeset} =
        %Gear{}
        |> Gear.changeset(attrs)
        |> Repo.insert()

      refute changeset.valid?

      assert "has already been taken" in errors_on(changeset).strava_id
    end

    test "errors if no athlete in DB" do
      attrs = %{
        athlete_id: Ecto.UUID.generate(),
        strava_id: "b1234",
        name: "SB150",
        primary: true
      }

      assert {:error, changeset} =
               %Gear{}
               |> Gear.changeset(attrs)
               |> Repo.insert()

      assert "does not exist" in errors_on(changeset).athlete_id
    end
  end
end
