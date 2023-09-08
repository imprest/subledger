defmodule Subledger.Repo do
  use Ecto.Repo,
    otp_app: :subledger,
    adapter: Ecto.Adapters.Postgres
end
