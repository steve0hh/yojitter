defmodule Yojitter.Twitter do
  @moduledoc """
  The Twitter context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Yojitter.Repo
  alias Yojitter.Twitter.TopTweetCache

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
  def list_top_tweets(server \\ TopTweetCache, n) do
    {:ok, list} = TopTweetCache.top_tweets(server, n)
    list
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

  Raises `Ecto.NoResultsError` if the Tweet does not exist.

  ## Examples

  iex> retweet_tweet!(123)
      %Tweet{}

      iex> retweet_tweet!(456) #non-existent id
      ** (Ecto.NoResultsError)
  """
  def retweet_tweet!(server \\ TopTweetCache, id) do
    now = NaiveDateTime.utc_now

    tweet = Repo.get!(Tweet, id)

    id = case tweet do
      %Tweet{parent_id: nil, id: tid} -> tid # original tweet
      %Tweet{parent_id: parent_id} -> parent_id # retweet case
    end

    retweet = Tweet.changeset(%Tweet{}, %{message: tweet.message, parent_id: id, retweeted_times: 0})

    increment = Tweet
                |> select([u], u)
                |> where(id: ^id)
                |> update([set: [updated_at: ^now]])
                |> update([inc: [retweeted_times: 1]])

    Multi.new()
    |> Multi.insert(:create_retweet, retweet)
    |> Multi.update_all(:inc_tweet, increment, [])
    |> Multi.run(:cache_tweet, fn(_repo, %{create_retweet: _, inc_tweet: {1, [tweet]}}) -> TopTweetCache.cache(server, tweet) end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_retweet: tweet, inc_tweet: {1, _}}} -> tweet
      error-> error
    end
  end
end
