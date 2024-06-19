defmodule SubledgerWeb.SubledgerChannel do
  @moduledoc "Main interface for client api"
  use SubledgerWeb, :channel

  alias Subledger.Books
  alias Subledger.Ledgers
  alias SubledgerWeb.Presence

  @impl true
  def join("subledger:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("subledger:" <> user_id, _payload, socket) do
    # if authorized?(payload) do
    if socket.assigns.user_id === String.to_integer(user_id) do
      org_id = socket.assigns.org_id
      socket = assign(socket, :books, Books.list_books(org_id))
      socket = assign(socket, :ledgers, Ledgers.get_ledger_permissions(user_id, org_id))
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (subledger:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("books:get", _payload, socket) do
    {:reply, Books.get_books(socket.assigns.org_id), socket}
  end

  @impl true
  def handle_in("ledgers:get", %{"fin_year" => fin_year}, socket) do
    user_id = socket.assigns.user_id
    book_id = fin_year_to_book_id(socket.assigns.books, fin_year)
    socket = assign(socket, :book_id, book_id)
    {:reply, Ledgers.list_ledgers(user_id, book_id), socket}
  end

  @impl true
  def handle_in("ledger:get", %{"code" => code, "fin_year" => fin_year}, socket) do
    IO.inspect code
    IO.inspect fin_year
    book_id = fin_year_to_book_id(socket.assigns.books, fin_year)
    {ledger_id, role} = Map.get(socket.assigns.ledgers, code)

    socket =
      socket
      |> assign(:fin_year, fin_year)
      |> assign(:book_id, book_id)
      |> assign(:code, code)
      |> assign(:ledger_id, ledger_id)
      |> assign(:role, role)

    {:reply, Ledgers.get_ledger(ledger_id, book_id), socket}
  end

  @impl true
  def handle_in("ledger:add_tx", %{"txs" => txs, "ledger_id" => ledger_id}, socket) do
    org_id = socket.assigns.org_id
    user_id = socket.assigns.user_id
    book_id = txs |> hd() |> Map.get("date") |> Date.from_iso8601!() |> date_to_book_id(socket.assigns.books)

    tx =
      txs
      |> hd()
      |> Map.put("ledger_id", ledger_id)
      |> Map.merge(%{"org_id" => org_id, "book_id" => book_id, "updated_by_id" => user_id, "inserted_by_id" => user_id})

    case Subledger.Ledgers.create_tx(tx) do
      {:ok, result} ->
        {:reply, Ledgers.get_ledger("1/FOUN", result.book_id), socket}

      {:error, reason} ->
        {:reply, %{error: reason}, socket}
    end
  end

  @impl true
  def handle_in("ledger:add_txs", %{"code" => code, "fin_year" => fin_year, "txs" => txs}, socket) do
    org_id = socket.assigns.org_id
    user_id = socket.assigns.user_id
    books = socket.assigns.books
    book_id = fin_year_to_book_id(books, fin_year)
    {ledger_id, _role} = Map.get(socket.assigns.ledgers, code)

    txs =
      for tx <- txs do
        book_id = tx |> Map.get("date") |> Date.from_iso8601!() |> date_to_book_id(books)

        tx
        |> Map.put("ledger_id", ledger_id)
        |> Map.merge(%{"org_id" => org_id, "book_id" => book_id, "updated_by_id" => user_id, "inserted_by_id" => user_id})
      end

    case Subledger.Ledgers.create_txs(txs) do
      :ok ->
        {:reply, Ledgers.get_ledger(ledger_id, book_id), socket}

      {:error, reason} ->
        {:reply, %{error: reason}, socket}
    end
  end

  @impl true
  def handle_in("ledger:delete_txs", %{"code" => code, "fin_year" => fin_year, "txs" => txs}, socket) do
    book_id = fin_year_to_book_id(socket.assigns.books, fin_year)
    {ledger_id, _role} = Map.get(socket.assigns.ledgers, code)

    case Subledger.Ledgers.delete_txs(txs) do
      :ok ->
        {:reply, Ledgers.get_ledger(ledger_id, book_id), socket}

      {:error, reason} ->
        {:reply, %{error: reason}, socket}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    # presence = Presence.get_by_key(socket, socket.assigns.name)
    # IO.inspect(presence, label: "Presence Data:")

    {:ok, _} =
      Presence.track(socket, socket.assigns.name, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  defp fin_year_to_book_id(books, 0), do: Map.get(hd(books), :id)

  defp fin_year_to_book_id(books, fin_year), do: books |> Enum.find(fn x -> x.fin_year == fin_year end) |> Map.get(:id)

  defp date_to_book_id(date, books) do
    book =
      Enum.find(books, fn x ->
        (Date.after?(date, x.period.lower) || Date.compare(date, x.period.lower) == :eq) &&
          Date.before?(date, x.period.upper)
      end)

    Map.get(book, :id)
  end
end
