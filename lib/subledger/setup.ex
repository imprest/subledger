defmodule Subledger.Setup do
  @moduledoc """
  The Setup context.
  """

  require Logger
  import MySigils
  alias Subledger.Repo
  alias Subledger.Setup.Book
  import Ecto.Query, only: [from: 2]

  def get_ledger(ledger_id) do
    q = ~Q"""
      SELECT row_to_json(j)::text as ledger 
      FROM (
        WITH op_bal AS (
          SELECT op_bal FROM ledgers WHERE id = $1
        ),
        txs AS (
          SELECT *,
          o.op_bal + (SUM(amount) OVER(ORDER BY date, id)) AS bal
          FROM tx, op_bal o WHERE ledger_id = $1
          ORDER BY date, id
        ),
        total_debit AS (SELECT COALESCE(SUM(amount), 0) as total_debit FROM txs WHERE amount >= 0),
        total_credit AS (SELECT COALESCE(SUM(amount), 0) as total_credit FROM txs WHERE amount < 0)
        SELECT id, name, code, is_gov, is_active, op_bal, 
        tin, town_city, country_id, region, number, address_1, address_2, 
          email, price_level, credit_limit, payment_terms, tags, book_id, currency_id,
        (SELECT total_debit FROM total_debit) AS total_debit,
        (SELECT total_credit FROM total_credit) AS total_credit,
        (SELECT op_bal+(SELECT total_debit FROM total_debit)+(SELECT total_credit FROM total_credit)) AS cl_bal,
        (SELECT COALESCE(json_agg(p), '[]'::json) FROM (SELECT * from txs) p) AS txs
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

  def list_ledgers(user_id, book_id) do
    q = ~Q"""
      SELECT COALESCE(json_agg(j), '[]'::json)::text as ledgers FROM (
        WITH scope AS (
          SELECT ledger_id, role FROM permissions
          WHERE user_id = $1
        ),
        txs AS (
          SELECT tx.ledger_id, SUM(tx.amount) as changes
          FROM tx
          WHERE book_id = $2
          GROUP BY tx.ledger_id
        )
        SELECT l.id, l.code, l.name, l.region, l.op_bal, (l.op_bal+t.changes) as cl_bal FROM ledgers l, txs t

        WHERE book_id = $2 AND l.id = t.ledger_id
        ORDER BY l.name
      ) j;
    """

    case Repo.query(q, [user_id, book_id]) do
      {:ok, %{num_rows: _cols, rows: rows}} ->
        {:ok, %{ledgers: Repo.json_frag(rows)}}

      {:error, Error} ->
        Logger.error(Error)
    end
  end

  def get_books_list(org_id) do
    q = from b in Book, where: b.org_id == ^org_id, select: b.id, order_by: [desc: b.fin_year]
    Repo.all(q, org_id: org_id)
  end

  def get_books(org_id) do
    q = ~Q"""
      SELECT COALESCE(json_agg(j), '[]'::json)::text as books FROM (
        SELECT id, fin_year, period FROM books
        WHERE org_id = $1
        ORDER BY fin_year desc
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
