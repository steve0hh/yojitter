defmodule YojitterWeb.TweetController do
  use YojitterWeb, :controller

  alias Yojitter.Twitter
  alias Yojitter.Twitter.Tweet

  def index(conn, _params) do
    tweets = Twitter.list_tweets()
    render(conn, "index.html", tweets: tweets)
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
    case Twitter.retweet_tweet(id) do
      {:ok, nil} ->
        conn
        |> put_flash(:info, "Tweet created successfully.")
        |> redirect(to: Routes.tweet_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Tweet not found")
        |> redirect(to: Routes.tweet_path(conn, :index))
    end

  end
end
