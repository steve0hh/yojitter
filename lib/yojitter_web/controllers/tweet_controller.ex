defmodule YojitterWeb.TweetController do
  use YojitterWeb, :controller

  alias Yojitter.Twitter
  alias Yojitter.Twitter.Tweet

  def index(conn, _params) do
    tweets = Twitter.list_top_tweets(10)
    render(conn, "index.html", tweets: tweets)
  end

  def all(conn, params) do
    page = params["page"] || 1
    tweets = Twitter.list_tweets(:paged, page, per_page: 10)
    render(conn, "all.html", tweets: tweets)
  end

  def new(conn, _params) do
    changeset = Twitter.change_tweet(%Tweet{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tweet" => tweet_params}) do
    case Twitter.create_tweet(tweet_params) do
      {:ok, tweet} ->
        conn
        |> put_flash(:info, "Tweet created successfully.")
        |> redirect(to: Routes.tweet_path(conn, :show, tweet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tweet = Twitter.get_tweet!(id)
    render(conn, "show.html", tweet: tweet)
  end

  def retweet(conn, %{"id" => id}) do
    tweet = Twitter.retweet_tweet!(id)
    conn
    |> put_flash(:info, "Tweet retweeted successfully.")
    |> redirect(to: Routes.tweet_path(conn, :show, tweet))
  end
end
