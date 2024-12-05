defmodule MySigils do
  @moduledoc false
  def sigil_Q(string, []), do: string

  def json_frag(rows), do: Jason.Fragment.new(rows)
end
