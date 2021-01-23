defmodule Yojitter.Twitter.TopTweetCacheTest do
  use ExUnit.Case, async: true

  use Yojitter.DataCase

  alias Yojitter.Twitter
  alias Yojitter.Twitter.Tweet
  alias Yojitter.Twitter.TopTweetCache

  @valid_attrs %{message: "some message"}

  def tweet_fixture(attrs \\ %{}) do
    {:ok, tweet} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Twitter.create_tweet()

    tweet
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Yojitter.Repo, {:shared, self()})
    pid = start_supervised!(TopTweetCache)
    {:ok , cache: pid}
  end

  test "cache/1 caches tweets", %{cache: cache} do
    tweet1 = tweet_fixture()
    assert {:ok, _} = TopTweetCache.cache(cache, tweet1)
    assert {:ok, [%Tweet{}]} = TopTweetCache.top_tweets(cache, 1)
  end

  test "top_tweets/2 returns top `n` tweets based on its `retweeted_times` count", %{cache: cache} do
    tweet1 = tweet_fixture(%{retweeted_times: 1})
    tweet2 = tweet_fixture(%{retweeted_times: 2})
    assert {:ok, _} = TopTweetCache.cache(cache, tweet1)
    assert {:ok, _} = TopTweetCache.cache(cache, tweet2)
    assert {:ok, returned_list} = TopTweetCache.top_tweets(cache, 2)
    assert [tweet2, tweet1] == returned_list
  end
end
