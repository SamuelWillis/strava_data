defmodule StravaData.Athletes.AthleteTest do
  use StravaData.DataCase, async: true

  alias StravaData.Athletes.Athlete

  describe "changset/2" do
    test "requires strava id" do
      attrs = %{}

      changeset = Athlete.changeset(%Athlete{}, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).strava_id
    end
  end
end
