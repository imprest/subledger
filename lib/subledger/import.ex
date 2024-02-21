defmodule Subledger.Import do
  @moduledoc false
  import Ecto.Query

  alias Decimal, as: D
  alias Subledger.Books
  alias Subledger.Ledgers.Ledger
  alias Subledger.Ledgers.Tx
  alias Subledger.Repo
  alias Subledger.Users.Permission

  require Logger

  @data_folder "/home/hvaria/Documents/backup"
  @folder_prefix "MGP"
  @mgp_folder @data_folder <> "/MGP"
  @dbf_files %{
    :subledgers => "FISLMST.DBF"
  }
  @default_date Date.from_iso8601!("2016-10-01")
  @default_time Time.from_iso8601!("08:00:00")
  # @default_datetime DateTime.new!(~D[2016-10-01], ~T[08:00:00], "Etc/UTC")
  @base_fin_year 2016

  defp tx_dbf_files(year) do
    y1_suffix = year |> to_string() |> String.slice(2..3)
    y2_suffix = year |> Kernel.+(1) |> to_string() |> String.slice(2..3)
    full_path = Path.join(@data_folder, @folder_prefix <> y1_suffix)

    %{
      :oct => Path.join(full_path, "FIT" <> y1_suffix <> "10.dbf"),
      :nov => Path.join(full_path, "FIT" <> y1_suffix <> "11.dbf"),
      :dec => Path.join(full_path, "FIT" <> y1_suffix <> "12.dbf"),
      :jan => Path.join(full_path, "FIT" <> y2_suffix <> "01.dbf"),
      :feb => Path.join(full_path, "FIT" <> y2_suffix <> "02.dbf"),
      :mar => Path.join(full_path, "FIT" <> y2_suffix <> "03.dbf"),
      :apr => Path.join(full_path, "FIT" <> y2_suffix <> "04.dbf"),
      :may => Path.join(full_path, "FIT" <> y2_suffix <> "05.dbf"),
      :jun => Path.join(full_path, "FIT" <> y2_suffix <> "06.dbf"),
      :jul => Path.join(full_path, "FIT" <> y2_suffix <> "07.dbf"),
      :aug => Path.join(full_path, "FIT" <> y2_suffix <> "08.dbf"),
      :sep => Path.join(full_path, "FIT" <> y2_suffix <> "09.dbf")
    }
  end

  defp years_to_sync do
    today = Date.utc_today()
    year = today.year
    month = today.month

    if month >= 10 do
      Enum.to_list(@base_fin_year..year)
    else
      Enum.to_list(@base_fin_year..(year - 1))
    end
  end

  defp gen_dbf_files(year) do
    full_path = @mgp_folder <> (year |> to_string() |> String.slice(2..3))
    for {k, v} <- @dbf_files, into: %{}, do: {k, Path.join(full_path, v)}
  end

  def make_user_1_owner do
    ids = Repo.all(from p in Permission, select: p.ledger_id, where: p.org_id == 1)

    new_ids = Repo.all(from l in Ledger, select: l.id, where: l.org_id == 1 and l.id not in ^ids)

    permissions =
      for x <- new_ids,
          do: %{
            ledger_id: x,
            org_id: 1,
            user_id: 1,
            role: :owner,
            inserted_by_id: 1,
            updated_by_id: 1,
            inserted_at: DateTime.utc_now(:second),
            updated_at: DateTime.utc_now(:second)
          }

    Repo.insert_all(Permission, permissions)
  end

  def all_fin_years do
    for year <- years_to_sync(), do: fin_year(year)
  end

  def fin_year(year) do
    f = Map.merge(gen_dbf_files(year), tx_dbf_files(year))

    book_id = year |> Books.get_book_by_year!() |> Map.get(:id)

    ctx = %{
      :org_id => 1,
      :year => year,
      :book_id => book_id,
      :start_date => Date.new!(year, 10, 1),
      :end_date => Date.new!(year + 1, 10, 1),
      :upserted => %{},
      :ledger_code_to_id => %{}
    }

    with :ok <- ensure_files_exist?(f),
         {:ok, ctx} <- import_subledgers(ctx, f.subledgers),
         {:ok, ctx} <- import_tx(ctx, f.oct),
         {:ok, ctx} <- import_tx(ctx, f.nov),
         {:ok, ctx} <- import_tx(ctx, f.dec),
         {:ok, ctx} <- import_tx(ctx, f.jan),
         {:ok, ctx} <- import_tx(ctx, f.feb),
         {:ok, ctx} <- import_tx(ctx, f.mar),
         {:ok, ctx} <- import_tx(ctx, f.apr),
         {:ok, ctx} <- import_tx(ctx, f.may),
         {:ok, ctx} <- import_tx(ctx, f.jun),
         {:ok, ctx} <- import_tx(ctx, f.jul),
         {:ok, ctx} <- import_tx(ctx, f.aug),
         {:ok, ctx} <- import_tx(ctx, f.sep) do
      Logger.info("Imported #{ctx.year}:\n#{inspect(Map.drop(ctx, [:year, :ledger_code_to_id]), pretty: true)}")
    else
      unexpected ->
        Logger.error("Error occurred #{inspect(%{:error => unexpected})}")
    end
  end

  defp ensure_files_exist?(files) do
    if Enum.reduce(files, fn {_, v}, acc -> acc && File.exists?(v) end) do
      :ok
    else
      {:error, "Could not find all necessary DBF files."}
    end
  end

  defp import_subledgers(ctx, dbf) do
    ledgers =
      ExDbase.parse(
        dbf,
        [
          "SL_GLCD",
          "SL_CODE",
          "SL_GRP",
          "SL_DESC",
          "SL_ADD1",
          "SL_ADD2",
          "SL_PHONE",
          "SL_EMAIL",
          "SL_FAX",
          "SL_MOBILE",
          "SL_STNO",
          "SL_OPBAL",
          "SL_LMU",
          "SL_LMD"
        ],
        fn x ->
          if x["SL_GLCD"] === "203000" do
            %{
              org_id: 1,
              is_active: true,
              currency_id: "GHS",
              is_gov:
                if x["SL_FAX"] === "GOV" do
                  true
                else
                  false
                end,
              book: %{book_id: ctx.book_id, op_bal: Decimal.new(x["SL_OPBAL"]), org_id: 1},
              code: x["SL_CODE"],
              name: x["SL_DESC"],
              tin: x["SL_STNO"],
              address_1: x["SL_ADD1"],
              address_2: x["SL_ADD2"],
              town_city: x["SL_ADD2"],
              country_id: "GHA",
              region: x["SL_GRP"],
              number: x["SL_PHONE"],
              email: x["SL_EMAIL"],
              credit_limit: D.new(0),
              payment_terms: "Cash or Immediate Chq.",
              tags: [x["SL_MOBILE"]],
              updated_by_id: 1,
              inserted_by_id: 1,
              inserted_at: to_timestamp(x["SL_LMD"], x["SL_LMT"]),
              updated_at: to_timestamp(x["SL_LMD"], x["SL_LMT"])
            }
          end
        end
      )

    upsert_ledgers = Enum.map(ledgers, fn x -> Map.drop(x, [:book]) end)

    # Upsert ledgers
    {rows, _} =
      Repo.insert_all(Ledger, upsert_ledgers,
        conflict_target: [:org_id, :code],
        on_conflict: {:replace_all_except, [:id]}
      )

    # Get Map of %{code => ledger_id}
    ledger_ids =
      for {code, id} <- Repo.all(from l in Ledger, select: {l.code, l.id}), reduce: %{} do
        acc -> Map.put(acc, code, id)
      end

    # Generate books_ledgers records i.e. assoc books to ledgers and it's op_bal
    upsert_books_ledgers =
      Enum.map(ledgers, fn x ->
        book = x.book
        ledger_id = Map.get(ledger_ids, x.code)
        Map.put(book, :ledger_id, ledger_id)
      end)

    # Insert op_bal
    {op_rows, _} =
      Repo.insert_all(Books.BookLedger, upsert_books_ledgers,
        conflict_target: [:org_id, :book_id, :ledger_id],
        on_conflict: :replace_all
      )

    ctx = %{ctx | upserted: Map.put(ctx.upserted, :op_bals, op_rows)}
    ctx = %{ctx | ledger_code_to_id: ledger_ids}
    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :ledgers, rows)}}
  end

  defp old_tx_id(date, type, code, noc, non) do
    List.to_string([date, " ", type, " ", code, " ", noc, "/", Integer.to_string(non)])
  end

  def import_tx(ctx, dbf) do
    book_id = ctx.book_id

    txs =
      ExDbase.parse(
        dbf,
        [
          "TR_TYPE",
          "TR_CODE",
          "TR_NON",
          "TR_NOC",
          "TR_SRNO",
          "TR_DATE",
          "TR_GLCD",
          "TR_SLCD",
          "TR_DRCR",
          "TR_AMT",
          "TR_DESC",
          "TR_QTY",
          "TR_LMU",
          "TR_LMD",
          "TR_LMT"
        ],
        fn x ->
          if x["TR_GLCD"] === "203000" do
            ledger_id = Map.get(ctx.ledger_code_to_id, x["TR_SLCD"])

            tmp = %{
              id: Uniq.UUID.uuid7(),
              book_id: book_id,
              org_id: ctx.org_id,
              date: to_date(x["TR_DATE"]),
              narration:
                if x["TR_TYPE"] == "SA" or x["TR_TYPE"] == "SB" do
                  x["TR_NOC"] <> "/" <> Integer.to_string(x["TR_NON"])
                else
                  if String.length(String.trim(x["TR_DESC"])) == 0 do
                    if String.length(String.trim(x["TR_QTY"])) != 0 do
                      clean_string(String.trim(x["TR_QTY"]))
                    else
                      " "
                    end
                  else
                    if String.length(String.trim(x["TR_QTY"])) != 0 do
                      clean_string(String.trim(x["TR_DESC"] <> " | " <> x["TR_QTY"]))
                    else
                      clean_string(String.trim(x["TR_DESC"]))
                    end
                  end
                end,
              ref_id: old_tx_id(x["TR_DATE"], x["TR_TYPE"], x["TR_CODE"], x["TR_NOC"], x["TR_NON"]),
              type: x["TR_TYPE"],
              ledger_id: ledger_id,
              amount:
                case x["TR_DRCR"] do
                  "D" ->
                    Decimal.new(x["TR_AMT"])

                  "C" ->
                    D.mult(Decimal.new(x["TR_AMT"]), -1)

                  _ ->
                    Decimal.new(x["TR_AMT"])
                end,
              updated_by_id: 1,
              inserted_by_id: 1,
              inserted_at: to_timestamp(x["TR_LMD"], x["TR_LMT"]),
              updated_at: to_timestamp(x["TR_LMD"], x["TR_LMT"])
            }

            case tmp.type do
              "SA" ->
                tmp
                |> Map.put(:type, :invoice)
                |> Map.put(:is_paid, true)

              "SB" ->
                tmp
                |> Map.put(:type, :invoice)
                |> Map.put(:is_paid, true)

              "BP" ->
                Map.put(tmp, :type, :rtn_chq)

              "BR" ->
                if String.contains?(tmp.ref_id, " CA ") do
                  Map.put(tmp, :type, :cash)
                else
                  if String.contains?(tmp.narration, "momo") do
                    Map.put(tmp, :type, :momo)
                  else
                    if String.contains?(tmp.narration, "cash") do
                      Map.put(tmp, :type, :cash)
                    else
                      Map.put(tmp, :type, :chq)
                    end
                  end
                end

              "JV" ->
                if x["TR_DRCR"] === "D" do
                  Map.put(tmp, :type, :debit)
                else
                  if String.contains?(tmp.narration, "tcc") do
                    Map.put(tmp, :type, :tcc)
                  else
                    Map.put(tmp, :type, :write_off)
                  end
                end
            end
          end
        end
      )

    # Get list of txs = %{ref_id => %{id, updated_at}}
    db_tx =
      for x <-
            Repo.all(from i in "txs", select: [:id, :ref_id, :updated_at], where: [book_id: ^book_id]),
          into: %{},
          do: {x.ref_id, x}

    # Determine tx to be inserted or updated i.e. upserted
    upsert_tx =
      Enum.reduce(txs, [], fn x, acc ->
        case db_tx[x.ref_id] do
          nil ->
            [x | acc]

          y ->
            if Date.compare(x.updated_at, y.updated_at) === :gt do
              [Map.put(x, :id, y.id) | acc]
            else
              acc
            end
        end
      end)

    # Upsert tx
    {rows, _} = Repo.insert_all(Tx, upsert_tx, conflict_target: [:id], on_conflict: {:replace_all_except, [:id]})

    # Upsert tx
    {:ok, %{ctx | upserted: Map.put(ctx.upserted, Path.basename(dbf, ".dbf"), rows)}}
  end

  defp to_timestamp(lmd, lmt), do: DateTime.new!(to_date(lmd), to_time(lmt))

  defp to_date(<<y0, y1, y2, y3, m0, m1, d0, d1>>) do
    Date.from_iso8601!(<<y0, y1, y2, y3, "-", m0, m1, "-", d0, d1>>)
  end

  defp to_date(""), do: @default_date
  defp to_date(nil), do: @default_date

  defp to_time(""), do: @default_time
  defp to_time(nil), do: @default_time
  defp to_time(time), do: Time.from_iso8601!(time)

  def clean_string(bin) do
    if String.valid?(bin) do
      bin
    else
      bin
      |> String.codepoints()
      |> Enum.filter(&String.valid?(&1))
      |> Enum.join()
    end
  end
end
