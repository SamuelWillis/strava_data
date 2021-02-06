defmodule StravaData.Activitys.ActivityTest do
  use StravaData.DataCase, async: true

  alias StravaData.Athletes.Activity

  describe "changset/2" do
    test "requires strava id" do
      attrs = %{}

      changeset = Activity.changeset(%Activity{}, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).strava_id
    end
  end
end
