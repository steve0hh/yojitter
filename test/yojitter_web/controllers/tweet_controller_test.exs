defmodule YojitterWeb.TweetControllerTest do
  use YojitterWeb.ConnCase

  alias Yojitter.Twitter

  @create_attrs %{message: "some message"}
  @invalid_attrs %{message: nil}

  def fixture(:tweet) do
    {:ok, tweet} = Twitter.create_tweet(@create_attrs)
    tweet
  end

  describe "index" do
    test "lists all tweets", %{conn: conn} do
      conn = get(conn, Routes.tweet_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Top 10 Tweets"
    end
  end

  describe "all" do
    test "lists all tweets", %{conn: conn} do
      conn = get(conn, Routes.tweet_path(conn, :all))
      assert html_response(conn, 200) =~ "Listing all Tweets"
    end
  end

  describe "new tweet" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tweet_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tweet"
    end
  end

  describe "create tweet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tweet_path(conn, :show, id)

      conn = get(conn, Routes.tweet_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tweet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tweet"
    end
  end
end
