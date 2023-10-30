defmodule Subledger.Setup do
  @moduledoc """
  The Setup context.
  """

  require Logger
  import MySigils
  alias Subledger.Repo

  def get_ledger(ledger_id) do
    q = ~Q"""
      SELECT COALESCE(to_json(j), '{}'::json)::text as ledger FROM (
      SELECT id, name, code, is_gov, is_active, op_bal, 
      tin, town_city, country_id, region, number, address_1, address_2, 
      email, price_level, credit_limit, payment_terms, tags, book_id, currency_id
        FROM ledgers where id = $1
      ) j;
    """

    case Repo.query(q, [ledger_id]) do
      {:ok, %{num_rows: 1, rows: rows}} ->
        {:ok, %{ledger: Repo.json_frag(hd(rows))}}

      {:error, Error} ->
        Logger.error(Error)
    end
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

      {:error, Error} ->
        Logger.error(Error)
    end
  end

  def get_books(org_id) do  
    q = ~Q"""
      SELECT COALESCE(json_agg(j), '[]'::json)::text as books FROM (
        SELECT id, fin_year, period FROM books
        WHERE org_id = $1
        ORDER BY fin_year
      ) j;
    """

    case Repo.query(q, [org_id]) do
      {:ok, %{num_rows: _cols, rows: rows}} ->
        {:ok, %{books: Repo.json_frag(rows)}}

      {:error, Error} ->
        Logger.error(Error)
    end
  end
end
