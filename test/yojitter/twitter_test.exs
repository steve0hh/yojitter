defmodule Yojitter.TwitterTest do
  use Yojitter.DataCase

  alias Yojitter.Twitter

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

    test "retweet_tweet!/1 returns a new tweet" do
      tweet = tweet_fixture()
      retweet = Twitter.retweet_tweet!(tweet.id)
      assert tweet.id == retweet.parent_id
      assert tweet.message == retweet.message
      assert tweet.retweeted_times == 0
    end

    test "retweet_tweet!/1 sets parent_id as retweet's parent_id when retweeting a retweet" do
      tweet = tweet_fixture()
      retweet1 = Twitter.retweet_tweet!(tweet.id)
      retweet2 = Twitter.retweet_tweet!(tweet.id)
      assert retweet1.parent_id == retweet2.parent_id
    end

    test "retweet_tweet!/1 increments the retweeted_times count" do
      tweet = tweet_fixture()
      Twitter.retweet_tweet!(tweet.id)
      parent = Twitter.get_tweet!(tweet.id)
      assert parent.retweeted_times == tweet.retweeted_times + 1
    end

    test "list_top_tweets/1 returns the top `n` most retweeted tweets" do
      popoular_tweet = tweet_fixture(%{retweeted_times: 10})
      tweet = tweet_fixture(%{retweeted_times: 0})
      assert Twitter.list_top_tweets(2) == [popoular_tweet, tweet]
    end
  end
end
