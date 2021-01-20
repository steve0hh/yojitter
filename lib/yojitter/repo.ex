defmodule Yojitter.Repo do
  use Ecto.Repo,
    otp_app: :yojitter,
    adapter: Ecto.Adapters.Postgres
end
