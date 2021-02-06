defmodule StravaData.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:strava_id, :bigint, null: false)
      add(:name, :string)
      add(:start_date_local, :utc_datetime)
      add(:distance, :float)
      add(:moving_time, :integer)
      add(:elapsed_time, :integer)
      add(:total_elevation_gain, :float)
      add(:type, :string)
      add(:achievement_count, :integer)
      add(:average_speed, :float)
      add(:max_speed, :float)

      add(:gear_id, references(:gear, type: :uuid, validate: true))
      add(:athlete_id, references(:athletes, type: :uuid, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:activities, [:strava_id]))
  end
end
