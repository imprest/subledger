defmodule Subledger.Books.BookLedger do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "books_ledgers" do
    field :org_id, :integer, primary_key: true
    belongs_to :book, Subledger.Books.Book, primary_key: true
    belongs_to :ledger, Subledger.Ledgers.Ledger, primary_key: true
    field :op_bal, :decimal
  end
end
