defmodule Subledger.Setup do
  @moduledoc """
  The Setup context.
  """

  require Logger
  import MySigils
  import Ecto.Query, warn: false
  alias Subledger.Repo
  alias Subledger.Setup

  def get_ledger(id) do
    Repo.get!(Setup.Ledger, id)
  end

  def list_ledgers(user_id) do
    q = ~Q"""
      SELECT COALESCE(json_agg(j), '[]'::json)::text as ledgers FROM (
        WITH scope AS (
          SELECT ledger_id, role FROM permissions
          WHERE user_id = $1
        )
        SELECT l.*, s.role FROM ledgers l
        LEFT JOIN scope s on s.ledger_id = l.id
        ORDER BY l.name
      ) j;
    """

    case Repo.query(q, [user_id]) do
      {:ok, %{num_rows: _cols, rows: rows}} ->
        {:ok, %{ledgers: Repo.json_frag(rows)}}

      {:error, _} ->
        Logger.error("Error in list_ledgers")
    end
  end
end
