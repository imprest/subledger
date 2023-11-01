defmodule Subledger.Data.Import do
  require Logger

  alias Subledger.Repo
  alias Subledger.Setup
  alias Subledger.Data.Dbase
  alias Decimal, as: D
  import Ecto.Query

  @data_folder "/home/hvaria/Documents/backup"
  @folder_prefix "MGP"
  @mgp_folder @data_folder <> "/MGP"
  @dbf_files %{
    :subledgers => "FISLMST.DBF"
  }
  @default_date Date.from_iso8601!("2016-10-01")
  @default_time Time.from_iso8601!("08:00:00")
  @default_datetime DateTime.new!(~D[2016-10-01], ~T[08:00:00], "Etc/UTC")
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

  defp years_to_sync() do
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

  def all_fin_years() do
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

    IO.inspect(ctx)
    # TODO: Don't import items from dbf but from own maintained csv else id's will inc on each
    # import if done via Repo.insert_all on_conflict
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
                if x["SL_FAX"] == "GOV" do
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
              town_city: x["SL_ADD2"],
              country_id: "GHA",
              region: x["SL_GRP"],
              number: x["SL_PHONE"],
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

    IO.inspect(ledgers)
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

    tx =
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
          tmp = %{
            book_id: book_id,
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
            ref_id: old_tx_id(x["TR_DATE"], x["TR_TYPE"], x["TR_CODE"], x["TR_NOC"], x["TR_NON"]),
            sr_no: x["TR_SRNO"],
            dr_cr: x["TR_DRCR"],
            type:
              case x["TR_TYPE"] do
                "SB" -> :SA
                _ -> String.to_atom(x["TR_TYPE"])
              end,
            amount: Decimal.new(x["TR_AMT"]),
            updated_by_id: Map.get(ctx.user_ids, x["DR_LMU"], 1),
            inserted_by_id: Map.get(ctx.user_ids, x["DR_LMU"], 1),
            inserted_at: to_timestamp(x["TR_LMD"], x["TR_LMT"]),
            updated_at: to_timestamp(x["TR_LMD"], x["TR_LMT"])
          }

          case tmp.type do
            :SA ->
              Map.merge(tmp, %{
                cr_ledger_id: tmp.book_id <> "_301000",
                dr_ledger_id:
                  if String.length(String.trim(x["TR_SLCD"])) !== 0 do
                    tmp.book_id <> "_" <> x["TR_GLCD"] <> "_" <> x["TR_SLCD"]
                  else
                    tmp.book_id <> "_" <> x["TR_GLCD"]
                  end
              })

            :BR ->
              Map.merge(tmp, %{
                cr_ledger_id:
                  if String.length(String.trim(x["TR_SLCD"])) !== 0 do
                    tmp.book_id <> "_" <> x["TR_GLCD"] <> "_" <> x["TR_SLCD"]
                  else
                    tmp.book_id <> "_" <> x["TR_GLCD"]
                  end,
                dr_ledger_id: ctx.bank_codes[x["TR_CODE"]]
              })

            :BP ->
              Map.merge(tmp, %{
                dr_ledger_id:
                  if String.length(String.trim(x["TR_SLCD"])) !== 0 do
                    tmp.book_id <> "_" <> x["TR_GLCD"] <> "_" <> x["TR_SLCD"]
                  else
                    tmp.book_id <> "_" <> x["TR_GLCD"]
                  end,
                cr_ledger_id: ctx.bank_codes[x["TR_CODE"]]
              })

            # Be very careful in modifying CR and CP code
            :CR ->
              Map.merge(
                tmp,
                %{
                  cr_ledger_id: "106999",
                  dr_ledger_id: ctx.bank_codes[x["TR_CODE"]]
                }
              )

            # Be very careful in modifying CR and CP code
            :CP ->
              Map.merge(
                tmp,
                %{
                  cr_ledger_id: ctx.bank_codes[x["TR_CODE"]],
                  dr_ledger_id: "106999"
                }
              )

            :JV ->
              Map.merge(
                tmp,
                %{
                  dr_ledger_id:
                    if String.length(String.trim(x["TR_SLCD"])) !== 0 do
                      tmp.book_id <> "_" <> x["TR_GLCD"] <> "_" <> x["TR_SLCD"]
                    else
                      tmp.book_id <> "_" <> x["TR_GLCD"]
                    end,
                  cr_ledger_id:
                    if String.length(String.trim(x["TR_SLCD"])) !== 0 do
                      tmp.book_id <> "_" <> x["TR_GLCD"] <> "_" <> x["TR_SLCD"]
                    else
                      tmp.book_id <> "_" <> x["TR_GLCD"]
                    end
                }
              )
          end
        end
      )

    # This is tricky code so check the private function for details
    tx = consolidate_CR_CP_into_CO(tx)

    anomaly =
      Enum.filter(tx, fn x -> x.dr_ledger_id === "106999" || x.cr_ledger_id === "106999" end)

    IO.inspect(anomaly, label: "ANOMALY")

    # Get list of current ref_id, update_at tx
    db_tx =
      for x <-
            Repo.all(from(i in "tx", select: [:id, :ref_id, :updated_at])),
          into: %{},
          do: {x.ref_id, x}

    # Determine tx to be inserted or updated i.e. upserted
    upsert_tx =
      Enum.reduce(tx, [], fn x, acc ->
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

    # Delete ids that are in upsert_tx -> also present in db
    # This is required since we want to cascade delete tx_entries associated with updated tx
    ids = for x <- upsert_tx, Map.get(x, :id) !== nil, do: x.id
    Repo.query!("DELETE FROM tx WHERE id = ANY($1)", [ids])

    last_tx_no =
      case Repo.one(from(t in "tx", select: max(t.id), where: t.book_id == ^book_id)) do
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
        x = Map.drop(x, [:amount, :dr_cr, :sr_no, :cr_ledger_id, :dr_ledger_id])

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
      Repo.insert_all(Fin.Tx, tx_with_ids,
        conflict_target: [:id],
        on_conflict: {:replace_all_except, [:id]}
      )

    ctx = %{ctx | upserted: Map.put(ctx.upserted, Path.basename(dbf, ".dbf"), rows)}

    # Get list of current ref_id -> tx.id as tx_refs
    tx_refs =
      for x <- tx_with_ids, reduce: %{} do
        acc -> Map.put_new(acc, x.ref_id, x.id)
      end

    # Filter tx_entries that were upserted from tx_refs
    tx_entries =
      for x <- tx, Map.has_key?(tx_refs, x.ref_id), do: Map.put_new(x, :id, tx_refs[x.ref_id])

    tx_entries =
      tx_entries
      |> Enum.group_by(& &1.id)
      |> Enum.reduce([], fn {_, v}, acc ->
        if Enum.count(v) === 1 do
          y = hd(v)

          [
            %{
              book_id: y.book_id,
              tx_id: y.id,
              sr_no: 2,
              ledger_id: y.cr_ledger_id,
              amount: D.mult(-1, y.amount)
            },
            %{
              book_id: y.book_id,
              tx_id: y.id,
              sr_no: 1,
              ledger_id: y.dr_ledger_id,
              amount: y.amount
            }
            | acc
          ]
        else
          case Map.get(hd(v), :type) do
            :JV ->
              [
                v
                |> Enum.reverse()
                |> Enum.map(fn x ->
                  %{
                    book_id: x.book_id,
                    tx_id: x.id,
                    sr_no: x.sr_no,
                    ledger_id: if(x.dr_cr === "D", do: x.dr_ledger_id, else: x.cr_ledger_id),
                    amount: if(x.dr_cr === "D", do: x.amount, else: D.mult(-1, x.amount))
                  }
                end)
                | acc
              ]

            _ ->
              entries =
                v
                |> Enum.reverse()
                |> Enum.map(fn x ->
                  %{
                    book_id: x.book_id,
                    tx_id: x.id,
                    sr_no: x.sr_no,
                    ledger_id: if(x.dr_cr === "D", do: x.dr_ledger_id, else: x.cr_ledger_id),
                    amount: if(x.dr_cr === "D", do: x.amount, else: D.mult(-1, x.amount))
                  }
                end)

              sr_no_max = Enum.map(v, & &1.sr_no) |> Enum.max()
              sr_no_max = sr_no_max + 1
              x = hd(v)

              sum =
                for x <- Enum.map(v, & &1.amount), reduce: D.new(0) do
                  acc -> D.add(x, acc)
                end

              extra_tx_entry = %{
                book_id: x.book_id,
                tx_id: x.id,
                sr_no: sr_no_max,
                ledger_id: if(x.dr_cr === "D", do: x.cr_ledger_id, else: x.dr_ledger_id),
                amount: if(x.dr_cr === "D", do: D.mult(-1, sum), else: sum)
              }

              [
                entries,
                extra_tx_entry
                | acc
              ]
          end
        end
      end)
      |> List.flatten()
      |> Enum.sort_by(& &1.tx_id, :asc)

    # Upsert tx entries
    {r, _} = Repo.insert_all(Fin.TxEntry, tx_entries)
    {:ok, %{ctx | upserted: Map.put(ctx.upserted, Path.basename(dbf, ".dbf") <> "_entries", r)}}
  end

  # This is tricky code so be very careful in modifing
  # It basically merges Contra entries of type CR & CP into a new type CO transaction
  # We are using the fact that CR entry from dbf will have it's correspoding CP entry maybe next
  # or few records afterwards and visa-versa.
  # If it is not CR/CP entry just add to acc without modifying the tx
  # CO will have 1 transaction_id but 2 tx_entries to show the contra transaction
  defp consolidate_CR_CP_into_CO(tx) do
    consolidate_CR_CP_into_CO(tx, nil, [])
  end

  defp consolidate_CR_CP_into_CO([], nil, acc), do: acc

  defp consolidate_CR_CP_into_CO([h | t], contra, acc) do
    if h.type === :CR || h.type === :CP do
      case contra do
        nil ->
          consolidate_CR_CP_into_CO(t, h, acc)

        _ ->
          if h.type === :CR do
            x = h |> Map.replace!(:cr_ledger_id, contra.cr_ledger_id) |> Map.replace!(:type, :CO)
            consolidate_CR_CP_into_CO(t, nil, [x | acc])
          else
            x = h |> Map.replace!(:dr_ledger_id, contra.dr_ledger_id) |> Map.replace!(:type, :CO)
            consolidate_CR_CP_into_CO(t, nil, [x | acc])
          end
      end
    else
      consolidate_CR_CP_into_CO(t, contra, [h | acc])
    end
  end

  defp gen_id(book_id, number),
    do: "#{book_id}_#{String.pad_leading(Integer.to_string(number), 10, "0")}"

  defp to_bool("T"), do: true
  defp to_bool("Y"), do: true
  defp to_bool("F"), do: false
  defp to_bool("N"), do: false
  defp to_bool(""), do: false
  defp nil?(""), do: nil
  defp nil?(string), do: string

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
