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
  end
end