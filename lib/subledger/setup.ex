defmodule Subledger.Setup do
  @moduledoc """
  The Setup context.
  """

  import Ecto.Query, warn: false
  alias Subledger.Repo
  alias Subledger.Setup

  def get_ledger(id) do
    IO.inspect id
    Repo.get!(Setup.Ledger, id)
  end


end
