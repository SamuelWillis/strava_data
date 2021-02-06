defmodule StravaData.Repo.Migrations.CreateAthletes do
  use Ecto.Migration

  def change do
    create table(:athletes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:strava_id, :bigint, null: false)
      add(:first_name, :string)
      add(:last_name, :string)
      add(:username, :string)
      add(:profile_picture, :string)

      timestamps()
    end

    create(unique_index(:athletes, [:strava_id]))
  end
end
