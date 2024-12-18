defmodule Subledger.Ledgers do
  @moduledoc """
  The Ledgers context.
  """

  import Ecto.Query, warn: false
  import MySigils

  alias Subledger.Accounts.Permission
  alias Subledger.Books.Ledger
  alias Subledger.Books.Tx
  alias Subledger.Repo

  require Logger

  @doc """
  Returns the list of ledgers that user_id can view and their closing balance based on that book_id

  ## Examples

      iex> list_ledgers()
      [%Ledger{}, ...]

  """
  # def list_ledgers do
  #   Repo.all(Ledger)
  # end
  def list_ledgers(user_id, book_id) do
    q = ~Q"""
      SELECT COALESCE(json_agg(j), '[]'::json)::text as ledgers FROM (
        WITH scope AS (
          SELECT ledger_id, role FROM permissions
          WHERE user_id = $1
        ),
        op_bal AS (
          SELECT b.op_bal, b.ledger_id FROM books_ledgers b, scope s
          WHERE s.ledger_id = b.ledger_id AND book_id = $2
        ),
        trans AS (
          SELECT t.ledger_id, 
            SUM(COALESCE(amount, 0)) FILTER (WHERE amount >= 0) as total_debit,
            SUM(COALESCE(amount, 0)) FILTER (WHERE amount < 0) as total_credit
          FROM txs t, scope s
          WHERE (SELECT period FROM books WHERE id = $2) @> t.date
          AND t.ledger_id = s.ledger_id
          GROUP BY t.ledger_id
        )
        SELECT l.id, l.code, l.name, l.region, o.op_bal, t.total_debit, t.total_credit,
          (o.op_bal+t.total_debit+t.total_credit) as cl_bal 
        FROM ledgers l, trans t, op_bal o
        WHERE l.id = t.ledger_id AND o.ledger_id = l.id
        ORDER BY l.name
      ) j;
    """

    case Repo.query(q, [user_id, book_id]) do
      {:ok, %{num_rows: _cols, rows: rows}} ->
        {:ok, %{ledgers: json_frag(rows)}}

      {:error, error} ->
        Logger.error(error)
    end
  end

  @doc """
  Gets a map of code => {:ledger_id, :role} for a given user depending on org_id and user permissions
  """
  def get_ledger_permissions(user_id, org_id) do
    q =
      from p in Permission,
        join: l in Ledger,
        on: l.id == p.ledger_id,
        where: p.user_id == ^user_id and p.org_id == ^org_id,
        select: {l.code, {p.ledger_id, p.role}}

    q |> Repo.all() |> Map.new()
  end

  @doc """
  Gets a single ledger.

  Raises `Ecto.NoResultsError` if the Ledger does not exist.

  ## Examples

      iex> get_ledger!(123)
      %Ledger{}

      iex> get_ledger!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ledger!(id), do: Repo.get!(Ledger, id)

  @doc """
  Gets a single ledger in json format

  Return {:ok, %{Ledger: ledger}} | {:error, Error} exist.
  """
  def get_ledger(ledger_id, book_id) do
    q = ~Q"""
      SELECT row_to_json(j)::text as ledger 
      FROM (
        WITH op_bal AS (
          SELECT op_bal, book_id FROM books_ledgers WHERE ledger_id = $1 AND book_id = $2
        ),
        period AS (
          SELECT period FROM books WHERE id = $2 
        ),
        trans AS (
          SELECT *,
          o.op_bal + (SUM(amount) OVER(ORDER BY date, id)) AS bal
          FROM txs, op_bal o, period p
          WHERE ledger_id = $1 AND  p.period @> date
          ORDER BY date, id
        ),
        total_debit AS (SELECT COALESCE(SUM(amount), 0) as total_debit FROM trans WHERE amount >= 0),
        total_credit AS (SELECT COALESCE(SUM(amount), 0) as total_credit FROM trans WHERE amount < 0)
        SELECT id, name, code, is_gov, is_active, o.op_bal, 
        tin, town_city, country_id, region, number, address_1, address_2, 
          email, price_level, credit_limit, payment_terms, tags, o.book_id, currency_id,
        (SELECT total_debit FROM total_debit) AS total_debit,
        (SELECT total_credit FROM total_credit) AS total_credit,
        (SELECT op_bal+(SELECT total_debit FROM total_debit)+(SELECT total_credit FROM total_credit)) AS cl_bal,
        (SELECT COALESCE(json_agg(p), '[]'::json) FROM (SELECT * from trans) p) AS txs 
        FROM op_bal o, ledgers WHERE id = $1
      ) j;
    """

    case Repo.query(q, [ledger_id, book_id]) do
      {:ok, %{num_rows: 1, rows: rows}} ->
        {:ok, %{ledger: json_frag(hd(rows))}}

      {:error, error} ->
        Logger.error(error)
    end
  end

  @doc """
  Creates a ledger.

  ## Examples

      iex> create_ledger(%{field: value})
      {:ok, %Ledger{}}

      iex> create_ledger(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ledger(attrs \\ %{}) do
    %Ledger{}
    |> Ledger.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ledger.

  ## Examples

      iex> update_ledger(ledger, %{field: new_value})
      {:ok, %Ledger{}}

      iex> update_ledger(ledger, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ledger(%Ledger{} = ledger, attrs) do
    ledger
    |> Ledger.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ledger.

  ## Examples

      iex> delete_ledger(ledger)
      {:ok, %Ledger{}}

      iex> delete_ledger(ledger)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ledger(%Ledger{} = ledger) do
    Repo.delete(ledger)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ledger changes.

  ## Examples

      iex> change_ledger(ledger)
      %Ecto.Changeset{data: %Ledger{}}

  """
  def change_ledger(%Ledger{} = ledger, attrs \\ %{}) do
    Ledger.changeset(ledger, attrs)
  end

  @doc """
  Returns the list of txs.

  ## Examples

      iex> list_txs()
      [%Tx{}, ...]

  """
  def list_txs do
    Repo.all(Tx)
  end

  @doc """
  Gets a single tx.

  Raises `Ecto.NoResultsError` if the Tx does not exist.

  ## Examples

      iex> get_tx!(123)
      %Tx{}

      iex> get_tx!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tx!(id), do: Repo.get!(Tx, id)

  @doc """
  Creates a tx.

  ## Examples

      iex> create_tx(%{field: value})
      {:ok, %Tx{}}

      iex> create_tx(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tx(attrs \\ %{}) do
    %Tx{}
    |> Tx.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates txs.

  ## Examples

      iex> create_txs([%{field: value}])
      {:ok, %Tx{}}

      iex> create_tx([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def create_txs(tx_maps) do
    txs =
      for tx <- tx_maps do
        Tx.changeset(%Tx{}, tx)
      end

    valid_changesets = Enum.map(txs, &Map.get(&1, :valid?))

    if Enum.all?(valid_changesets, fn x -> x end) do
      changes =
        for x <- txs do
          x.changes
          |> Map.put(:id, Uniq.UUID.uuid7())
          |> Map.put(:inserted_at, DateTime.utc_now(:second))
          |> Map.put(:updated_at, DateTime.utc_now(:second))
        end

      Repo.insert_all(Tx, changes)
      :ok
    else
      {:error, "There is an error in one of the txs"}
    end
  end

  @doc """
  Updates a tx.

  ## Examples

      iex> update_tx(tx, %{field: new_value})
      {:ok, %Tx{}}

      iex> update_tx(tx, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tx(%Tx{} = tx, attrs) do
    tx
    |> Tx.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tx.

  ## Examples

      iex> delete_tx(tx)
      {:ok, %Tx{}}

      iex> delete_tx(tx)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tx(%Tx{} = tx) do
    Repo.delete(tx)
  end

  @doc """
  Deletes a txs.

  ## Examples

      iex> delete_txs([tx_id])
      {:ok, %Tx{}}

      iex> delete_txs([tx_id])
      {:error, %Ecto.Changeset{}}

  """
  def delete_txs(txs) do
    case Repo.delete_all(from t in Tx, where: t.id in ^txs) do
      {_count, nil} -> :ok
      _ -> {:error, "Could not delete transactions."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tx changes.

  ## Examples

      iex> change_tx(tx)
      %Ecto.Changeset{data: %Tx{}}

  """
  def change_tx(%Tx{} = tx, attrs \\ %{}) do
    Tx.changeset(tx, attrs)
  end
end
