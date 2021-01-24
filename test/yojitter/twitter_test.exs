defmodule Yojitter.TwitterTest do
  use Yojitter.DataCase

  alias Yojitter.Twitter
  alias Yojitter.Twitter.TopTweetCache

  describe "tweets" do
    alias Yojitter.Twitter.Tweet

    @valid_attrs %{message: "some message"}
    @invalid_attrs %{message: nil}

    def tweet_fixture(attrs \\ %{}) do
      {:ok, tweet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Twitter.create_tweet()

      tweet
    end

    test "list_tweets/0 returns all tweets" do
      tweet = tweet_fixture()
      assert Twitter.list_tweets() == [tweet]
    end

    test "list_tweets/3 returns tweets specified by `per_page` parameter" do
      tweet_fixture()
      tweet2 = tweet_fixture()
      tweet3 = tweet_fixture()

      tweets_page = Twitter.list_tweets(:paged, 1, per_page: 2)

      assert tweets_page.list == [tweet3, tweet2]
    end

    test "get_tweet!/1 returns the tweet with given id" do
      tweet = tweet_fixture()
      assert Twitter.get_tweet!(tweet.id) == tweet
    end

    test "create_tweet/1 with valid data creates a tweet" do
      assert {:ok, %Tweet{} = tweet} = Twitter.create_tweet(@valid_attrs)
      assert tweet.message == "some message"
    end

    test "create_tweet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Twitter.create_tweet(@invalid_attrs)
    end

    test "create_tweet/1 with message length of more than 140 characters returns error changeset" do
      message = String.duplicate("a", 141)
      assert {:error, %Ecto.Changeset{}} = Twitter.create_tweet(%{message: message})
    end

    test "change_tweet/1 returns a tweet changeset" do
      tweet = tweet_fixture()
      assert %Ecto.Changeset{} = Twitter.change_tweet(tweet)
    end
  end

  describe "tweets functions that need to use cache" do
    setup do
      Ecto.Adapters.SQL.Sandbox.mode(Yojitter.Repo, {:shared, self()})
      pid = start_supervised!(TopTweetCache)
      {:ok , cache: pid}
    end

    test "retweet_tweet!/1 returns a new tweet", %{cache: cache} do
      tweet = tweet_fixture()
      retweet = Twitter.retweet_tweet!(cache, tweet.id)
      assert tweet.id == retweet.parent_id
      assert tweet.message == retweet.message
      assert tweet.retweeted_times == 0
    end

    test "retweet_tweet!/1 sets parent_id as retweet's parent_id when retweeting a retweet", %{cache: cache} do
      tweet = tweet_fixture()
      retweet1 = Twitter.retweet_tweet!(cache, tweet.id)
      retweet2 = Twitter.retweet_tweet!(cache, tweet.id)
      assert retweet1.parent_id == retweet2.parent_id
    end

    test "retweet_tweet!/1 increments the retweeted_times count", %{cache: cache} do
      tweet = tweet_fixture()
      Twitter.retweet_tweet!(cache, tweet.id)
      parent = Twitter.get_tweet!(tweet.id)
      assert parent.retweeted_times == tweet.retweeted_times + 1
    end

    test "list_top_tweets/1 returns the top `n` most retweeted tweets", %{cache: cache} do
      tweet1 = tweet_fixture(%{retweeted_times: 1})
      tweet2 = tweet_fixture(%{retweeted_times: 2})

      Twitter.retweet_tweet!(cache, tweet1.id) # retweet to trigger cache
      Twitter.retweet_tweet!(cache, tweet2.id) # retweet to trigger cache

      tweet1 = %{tweet1 | retweeted_times: 2} # increment retweet count
      tweet2 = %{tweet2 | retweeted_times: 3} # increment retweet count

      assert [tweet2, tweet1] == Twitter.list_top_tweets(cache, 2)
    end
  end
end
