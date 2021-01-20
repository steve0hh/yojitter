defmodule YojitterWeb.PageController do
  use YojitterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
