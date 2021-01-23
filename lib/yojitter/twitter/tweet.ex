defmodule Yojitter.Twitter.Tweet do
  alias Yojitter.Twitter.Tweet
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :message, :string
    field :retweeted_times, :integer, default: 0

    field :parent_id, :integer
    belongs_to :parent, Tweet, foreign_key: :parent_id, references: :id, define_field: false
    has_many :retweets, Tweet, foreign_key: :parent_id, references: :id
    timestamps()
  end

  @doc false
  def changeset(tweet, attrs) do
    tweet
    |> cast(attrs, [:message, :retweeted_times, :parent_id])
    |> validate_required([:message])
    |> validate_length(:message, max: 140)
  end
end
