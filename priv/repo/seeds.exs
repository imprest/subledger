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
alias Subledger.Books.Book
alias Subledger.Orgs
alias Subledger.Public
alias Subledger.Repo
alias Subledger.Users
alias Subledger.Users.User

inserted_at = ~U[2023-10-01 08:00:00Z]
updated_at = ~U[2023-10-01 08:00:00Z]

Repo.insert!(%Public.Country{id: "GHA", name: "Ghana"})

Repo.insert_all(
  Public.Currency,
  [
    %{id: "GHS", name: "Ghana Cedis", symbol: "Gh¢"},
    %{id: "USD", name: "U.S. Dollar", symbol: "$"},
    %{id: "EUR", name: "Euro", symbol: "€"},
    %{id: "GBP", name: "Great British Pound", symbol: "£"}
  ]
)

org =
  Repo.insert!(%Orgs.Org{
    id: 1,
    sname: "MGP",
    name: "M&G Pharmaceuticals Ltd",
    inserted_at: inserted_at,
    updated_at: updated_at
  })

org_id = org.id

{:ok, u} =
  Users.register_user(%{
    org_id: org_id,
    username: "hvaria",
    email: "hardikvaria@gmail.com",
    name: "Hardik Varia",
    password: "Testing12345",
    is_admin: true
  })

user_id = u.id

Repo.update!(User.confirm_changeset(u))

Repo.insert_all(Book, [
  %{
    org_id: org_id,
    fin_year: 2016,
    currency_id: "GHS",
    period: DateRange.new(~D[2016-10-01], ~D[2017-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2017,
    currency_id: "GHS",
    period: DateRange.new(~D[2017-10-01], ~D[2018-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2018,
    currency_id: "GHS",
    period: DateRange.new(~D[2018-10-01], ~D[2019-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2019,
    currency_id: "GHS",
    period: DateRange.new(~D[2019-10-01], ~D[2020-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2020,
    currency_id: "GHS",
    period: DateRange.new(~D[2020-10-01], ~D[2021-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2021,
    currency_id: "GHS",
    period: DateRange.new(~D[2021-10-01], ~D[2022-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2022,
    currency_id: "GHS",
    period: DateRange.new(~D[2022-10-01], ~D[2023-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  },
  %{
    org_id: org_id,
    fin_year: 2023,
    currency_id: "GHS",
    period: DateRange.new(~D[2023-10-01], ~D[2024-10-01]),
    inserted_by_id: user_id,
    updated_by_id: user_id,
    inserted_at: inserted_at,
    updated_at: updated_at
  }
])

