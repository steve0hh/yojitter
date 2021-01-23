defmodule Yojitter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Yojitter.Repo,
      # Start the Telemetry supervisor
      YojitterWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Yojitter.PubSub},
      # Start the Endpoint (http/https)
      YojitterWeb.Endpoint,
      # Start a worker by calling: Yojitter.Worker.start_link(arg)
      # {Yojitter.Worker, arg}
      {Yojitter.Twitter.TopTweetCache, name: Yojitter.Twitter.TopTweetCache},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Yojitter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    YojitterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
