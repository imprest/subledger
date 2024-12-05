# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Subledger.Repo.insert!(%Subledger.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PgRanges.DateRange
alias Subledger.Accounts
alias Subledger.Accounts.Org
alias Subledger.Accounts.User
alias Subledger.Books.Book
alias Subledger.Global
alias Subledger.Repo

inserted_at = ~U[2023-10-01 08:00:00Z]
updated_at = ~U[2023-10-01 08:00:00Z]

Repo.insert!(%Global.Country{id: "GHA", name: "Ghana"})

Repo.insert_all(
  Global.Currency,
  [
    %{id: "GHS", name: "Ghana Cedis", symbol: "Gh¢"},
    %{id: "USD", name: "U.S. Dollar", symbol: "$"},
    %{id: "EUR", name: "Euro", symbol: "€"},
    %{id: "GBP", name: "Great British Pound", symbol: "£"}
  ]
)

org =
  Repo.insert!(%Org{
    id: 1,
    sname: "MGP",
    name: "M&G Pharmaceuticals Ltd",
    inserted_at: inserted_at,
    updated_at: updated_at
  })

org_id = org.id

{:ok, u} =
  Accounts.register_user(%{
    org_id: org_id,
    username: "hvaria",
    email: "hardikvaria@gmail.com",
    name: "Hardik Varia",
    password: "Testing12345",
    is_admin: true
  })

user_id = u.id

Repo.update!(User.confirm_changeset(u))

books =
  [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024]
  |> Enum.map(fn year ->
    start_date = Date.new!(year, 10, 01)
    end_date = Date.shift(start_date, year: 1)

    %{
      org_id: org_id,
      fin_year: year,
      currency_id: "GHS",
      period: DateRange.new(start_date, end_date),
      inserted_by_id: user_id,
      updated_by_id: user_id,
      inserted_at: inserted_at,
      updated_at: updated_at
    }
  end)

Repo.insert_all(Book, books)
