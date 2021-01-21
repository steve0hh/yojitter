defmodule Yojitter.Twitter.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :message, :string
    field :retweeted_times, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(tweet, attrs) do
    tweet
    |> cast(attrs, [:message, :retweeted_times])
    |> validate_required([:message])
    |> validate_length(:message, max: 140)
  end
end
