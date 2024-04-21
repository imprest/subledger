defmodule Subledger.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  import MySigils

  alias Subledger.Books.Book
  alias Subledger.Repo

  require Logger

  @doc """
  Returns the list of books scope by org_id

  ## Examples

      iex> list_books(1)
      [%Book{}, ...]

  """
  def list_books(org_id) do
    q = from(b in Book, where: b.org_id == ^org_id, order_by: [desc: b.fin_year])
    Repo.all(q)
  end

  @doc """
  Returns the list of books scope by org_id but in json format

  ## Examples

      iex> list_books(1)
      {:ok %Book{}} | {error, %Error{}}

  """
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

      {:error, error} ->
        Logger.error(error)
    end
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Gets a book by the fin year.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book_by_year!(2016)
      %Book{}

      iex> get_book_by_year!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_by_year!(fin_year), do: Repo.get_by!(Book, fin_year: fin_year)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
