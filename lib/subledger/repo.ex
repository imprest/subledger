defmodule Subledger.Repo do
  use Ecto.Repo,
    otp_app: :subledger,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  @tenant_key {__MODULE__, :org_id}

  @impl true
  def default_options(_operations) do
    [org_id: get_org_id()]
  end

  @impl true
  def prepare_query(_operation, query, opts) do
    cond do
      opts[:skip_org_id] || opts[:schema_migration] ->
        {query, opts}

      org_id = opts[:org_id] ->
        {Ecto.Query.where(query, org_id: ^org_id), opts}

      true ->
        raise "expected org_id or skip_org_id to be set"
    end
  end

  def put_org_id(org_id), do: Process.put(@tenant_key, org_id)
  def get_org_id(), do: Process.get(@tenant_key)

  def json_frag(rows), do: Jason.Fragment.new(rows)
end
