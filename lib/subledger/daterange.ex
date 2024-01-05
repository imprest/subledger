defmodule Subledger.DateRange do
  @moduledoc """
  Wraps a `Postgrex.Range` and casts to PostgreSQL `daterange` type.
  """
  use Ecto.Type

  def type, do: :daterange

  def cast([lower, upper]) do
    {:ok, [lower, upper]}
  end

  def cast(_), do: :error

  def load(%Postgrex.Range{lower: lower, upper: upper}) do
    {:ok, Date.range(lower, Date.add(upper, -1))}
  end

  def dump([lower, upper]) do
    {:ok, %Postgrex.Range{lower: lower, upper: upper, upper_inclusive: false}}
  end

  def dump(_), do: :error
end
