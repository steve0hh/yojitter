defmodule Yojitter.Twitter.TopTweetCache do

  # defines the max number of tweets that can be cached in the queue
  @cache_limit 10

  use GenServer
  import Ecto.Query, warn: false
  alias Yojitter.Repo
  alias Yojitter.Twitter
  alias Yojitter.Twitter.Tweet

  @doc """
  Starts the cache.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Adds the tweet into the cache queue.
  """
  def cache(server \\ __MODULE__, tweet) do
    GenServer.call(server, {:cache, tweet})
  end

  @doc """
  Returns the top `n` tweets based on the amount of `retweeted_times`
  in descending order.
  """
  def top_tweets(server \\ __MODULE__, n) do
    GenServer.call(server, {:top_tweets, n})
  end


  @impl true
  def init(:ok) do

    # select tweets from database to hydrate state
    tweets = Tweet
    |> order_by(desc: :retweeted_times)
    |> limit(@cache_limit)
    |> Repo.all()

    {:ok, tweets}
  end

  @impl true
  def handle_call({:cache, tweet}, _from, state) do
    state =
      state
      |> Enum.concat([tweet])
      |> Enum.sort_by(fn(t)-> t.retweeted_times end, :desc)
      |> Enum.uniq_by(fn(t)-> t.id end)
      |> Enum.take(@cache_limit)

    {:reply, {:ok, {}}, state}
  end

  @impl true
  def handle_call({:top_tweets, n}, _from, state) do
    top_n =
      state
      |> Enum.sort_by(fn(t)-> t.retweeted_times end, :desc)
      |> Enum.uniq_by(fn(t)-> t.id end)
      |> Enum.take(n)

    {:reply, {:ok, top_n}, state}
  end
end
