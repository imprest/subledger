defmodule Subledger.Repo do
  use Ecto.Repo,
    otp_app: :subledger,
    adapter: Ecto.Adapters.Postgres

  def json_frag(rows), do: Jason.Fragment.new(rows)
end
