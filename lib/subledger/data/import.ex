defmodule Subledger.Data.Import do
  @moduledoc false
  require Logger

  import Ecto.Query

  alias Decimal, as: D
  alias Subledger.Data.Dbase
  alias Subledger.Repo
  alias Subledger.Setup

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
    y1_suffix = year |> to_string |> String.slice(2..3)
    y2_suffix = year |> Kernel.+(1) |> to_string |> String.slice(2..3)
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

    case month >= 10 do
      true -> Enum.to_list(@base_fin_year..year)
      false -> Enum.to_list(@base_fin_year..(year - 1))
    end
  end

  defp gen_dbf_files(year) do
    full_path = @mgp_folder <> (year |> to_string |> String.slice(2..3))
    for {k, v} <- @dbf_files, into: %{}, do: {k, Path.join(full_path, v)}
  end

  def all_fin_years do
    for year <- years_to_sync(), do: fin_year(year)
  end

  def fin_year(year) do
    f = Map.merge(gen_dbf_files(year), tx_dbf_files(year))

    ctx = %{
      :org_id => 1,
      :year => year,
      :book_id => "1_#{year}",
      :start_date => Date.new!(year, 10, 1),
      :end_date => Date.new!(year + 1, 10, 1),
      :upserted => %{}
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
      Logger.info("Imported #{ctx.year}:\n#{inspect(Map.drop(ctx, [:year]), pretty: true)}")
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
      Dbase.parse(
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
          "SL_OPBAL",
          "SL_LMU",
          "SL_LMD"
        ],
        fn x ->
          if x["SL_GLCD"] === "203000" do
            %{
              org_id: 1,
              id: ctx.book_id <> "_" <> x["SL_CODE"],
              is_active: true,
              currency_id: "GHS",
              is_gov:
                if x["SL_FAX"] === "GOV" do
                  true
                else
                  false
                end,
              book_id: ctx.book_id,
              code: x["SL_CODE"],
              op_bal: Decimal.new(x["SL_OPBAL"]),
              name: x["SL_DESC"],
              tin: "C000000000",
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
          else
            nil
          end
        end
      )

    # Get list of current %{id => updated_at} ledgers
    db_ledgers =
      for x <-
            Repo.all(from(i in "ledgers", select: [:id, :updated_at]), org_id: ctx.org_id),
          into: %{},
          do: {x.id, x}

    # Determine subledgers to be inserted or updated i.e. upserted
    upsert_ledgers =
      Enum.reduce(ledgers, [], fn x, acc ->
        case db_ledgers[x.id] do
          # id not in database ids so insert
          nil -> [x | acc]
          # id in db determine if it needs to be updated i.e. if updated_at > db record
          y -> if Date.compare(x.updated_at, y.updated_at) === :gt, do: [x | acc], else: acc
        end
      end)

    # Upsert items
    {rows, _} =
      Repo.insert_all(Setup.Ledger, upsert_ledgers,
        conflict_target: [:id],
        on_conflict: {:replace_all_except, [:id]}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :subledgers, rows)}}
  end

  defp old_tx_id(date, type, code, noc, non) do
    List.to_string([date, " ", type, " ", code, " ", noc, "/", Integer.to_string(non)])
  end

  def import_tx(ctx, dbf) do
    book_id = ctx.book_id

    txs =
      Dbase.parse(
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
            tmp = %{
              book_id: book_id,
              org_id: ctx.org_id,
              date: to_date(x["TR_DATE"]),
              narration:
                case x["TR_TYPE"] == "SA" or x["TR_TYPE"] == "SB" do
                  true ->
                    x["TR_NOC"] <> "/" <> Integer.to_string(x["TR_NON"])

                  false ->
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
              ref_id:
                old_tx_id(x["TR_DATE"], x["TR_TYPE"], x["TR_CODE"], x["TR_NOC"], x["TR_NON"]),
              dr_cr: x["TR_DRCR"],
              type: x["TR_TYPE"],
              ledger_id: book_id <> "_" <> x["TR_SLCD"],
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
              updated_at: to_timestamp(x["TR_LMD"], x["TR_LMT"]),
              verified_by_id: nil
            }

            case tmp.type do
              "SA" ->
                Map.put(tmp, :type, "invoice")

              "SB" ->
                Map.put(tmp, :type, "invoice")

              "BP" ->
                Map.put(tmp, :type, "rtn chq")

              "BR" ->
                if String.contains?(tmp.ref_id, " CA ") do
                  Map.put(tmp, :type, "cash")
                else
                  if String.contains?(tmp.narration, "momo") do
                    Map.put(tmp, :type, "momo")
                  else
                    if String.contains?(tmp.narration, "cash") do
                      Map.put(tmp, :type, "cash")
                    else
                      Map.put(tmp, :type, "chq")
                    end
                  end
                end

              "JV" ->
                if tmp.dr_cr === "D" do
                  Map.put(tmp, :type, "write-off")
                else
                  if String.contains?(tmp.narration, "tcc") do
                    Map.put(tmp, :type, "tcc")
                  else
                    Map.put(tmp, :type, "discount")
                  end
                end
            end
          else
            nil
          end
        end
      )

    # Get list of current ref_id, update_at tx
    db_tx =
      for x <-
            Repo.all(from(i in "tx", select: [:id, :ref_id, :updated_at]), org_id: ctx.org_id),
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
              # x = Map.put(x, :no, y.no)
              [Map.put(x, :id, y.id) | acc]
            else
              acc
            end
        end
      end)

    last_tx_no =
      case Repo.one(
             from(t in "tx",
               select: max(t.id),
               where: t.book_id == ^book_id
             ),
             skip_org_id: true
           ) do
        nil -> 1
        id -> String.split(id, "_") |> Enum.at(2) |> String.to_integer() |> Kernel.+(1)
      end

    {tx_with_ids, _} =
      upsert_tx
      |> Enum.group_by(& &1.ref_id)
      |> Enum.reduce([], fn {_, v}, acc ->
        [Enum.max_by(v, & &1.updated_at, DateTime) | acc]
      end)
      |> Enum.sort_by(& &1.ref_id)
      |> Enum.map_reduce(last_tx_no, fn x, acc ->
        x = Map.drop(x, [:dr_cr])

        if Map.has_key?(x, :id) do
          {x, acc}
        else
          {Map.put_new(
             x,
             :id,
             gen_id(book_id, acc)
           ), acc + 1}
        end
      end)

    # Upsert tx
    {rows, _} =
      Repo.insert_all(Setup.Tx, tx_with_ids,
        conflict_target: [:id],
        on_conflict: {:replace_all_except, [:id]}
      )

    # Upsert tx
    {:ok, %{ctx | upserted: Map.put(ctx.upserted, Path.basename(dbf, ".dbf"), rows)}}
  end

  defp gen_id(book_id, number),
    do: "#{book_id}_#{String.pad_leading(Integer.to_string(number), 10, "0")}"

  # defp to_bool("T"), do: true
  # defp to_bool("Y"), do: true
  # defp to_bool("F"), do: false
  # defp to_bool("N"), do: false
  # defp to_bool(""), do: false
  # defp nil?(""), do: nil
  # defp nil?(string), do: string

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
    case String.valid?(bin) do
      true ->
        bin

      false ->
        bin
        |> String.codepoints()
        |> Enum.filter(&String.valid?(&1))
        |> Enum.join()
    end
  end
end
