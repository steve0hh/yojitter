defmodule Yojitter.Twitter do
  @moduledoc """
  The Twitter context.
  """

  import Ecto.Query, warn: false
  alias Yojitter.Repo

  alias Yojitter.Twitter.Tweet

  @doc """
  Returns the list of tweets.

  ## Examples

      iex> list_tweets()
      [%Tweet{}, ...]

  """
  def list_tweets do
    Repo.all(Tweet)
  end

  @doc """
  Returns top `n` tweets with the most retweets

  ## Examples
      iex> list_top_tweets(2)
      [%Tweet{}, %Tweet{}]

      iex> list_top_tweets(10)
      [%Tweet{}, %Tweet{}, ...]
  """
  def list_top_tweets(n) do
    Tweet
    |> order_by(desc: :retweeted_times)
    |> limit(^n)
    |> Repo.all()
  end

  @doc """
  Gets a single tweet.

  Raises `Ecto.NoResultsError` if the Tweet does not exist.

  ## Examples

      iex> get_tweet!(123)
      %Tweet{}

      iex> get_tweet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tweet!(id), do: Repo.get!(Tweet, id)

  @doc """
  Creates a tweet.

  ## Examples

      iex> create_tweet(%{field: value})
      {:ok, %Tweet{}}

      iex> create_tweet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tweet(attrs \\ %{}) do
    %Tweet{}
    |> Tweet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tweet changes.

  ## Examples

      iex> change_tweet(tweet)
      %Ecto.Changeset{data: %Tweet{}}

  """
  def change_tweet(%Tweet{} = tweet, attrs \\ %{}) do
    Tweet.changeset(tweet, attrs)
  end


  @doc """
  Retweets a tweet by incrementing the `retweeted_times` and
  updates the `updated_at` fed.

  ## Examples

      iex> retweet_tweet(123)
      {:ok, nil}

      iex> retweet_tweet(456) #non-existent id
      {:error, :not_found}
  """
  def retweet_tweet(id) do
    now = NaiveDateTime.utc_now
    Tweet
    |> where(id: ^id)
    |> update([set: [updated_at: ^now]])
    |> update([inc: [retweeted_times: 1]])
    |> Repo.update_all([])
    |> case do
      {1, nil} -> {:ok, nil}
      {_, nil} -> {:error, :not_found}
    end
  end
end
