defmodule Yojitter.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add :message, :string
      add :retweeted_times, :integer

      timestamps()
    end

  end
end
