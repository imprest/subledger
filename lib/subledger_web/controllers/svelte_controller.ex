defmodule SubledgerWeb.SvelteController do
  use SubledgerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
