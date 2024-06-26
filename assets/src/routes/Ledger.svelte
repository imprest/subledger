<svelte:options runes={true} />

<script lang="ts">
  import { untrack } from 'svelte';
  import { appState, getLedger, deleteTxs, addTxs, type TxType, type Tx } from '../store.svelte';
  import { moneyFmt, dateFmt } from '../utils';
  import { push } from 'svelte-spa-router';

  type MyProps = { params: { code: string; fin_year: string } };
  let { params }: MyProps = $props();

  let ledgerStatus = $derived(appState.ledger.status);

  let ledger = $derived(appState.ledger.data);
  let selectedTxs = $derived(ledger!.txs.filter((x: Tx) => x.selected).map((x) => x.id));
  let fin_year = $derived.by(() => {
    if (params !== undefined && params.fin_year) {
      return parseInt(params.fin_year, 10);
    } else {
      return appState.books[0].fin_year;
    }
  });

  function goToLedger(code: string, year: number) {
    push(`#/ledger/${encodeURIComponent(code)}/${year}`);
  }

  $effect(() => {
    if (params !== undefined && params.fin_year) {
      untrack(() => getLedger(params.code, fin_year));
    } else {
      untrack(() => getLedger(params.code, fin_year));
    }
  });

  let selectAll = $state(false);
  $effect(() => {
    selectAll;
    if (ledger && ledger.txs.length > 0) {
      untrack(() => {
        ledger!.txs.map((tx) => (tx.selected = selectAll));
      });
    }
  });

  type newTx = {
    date: string;
    type: TxType;
    narration: string;
    debit?: number;
    credit?: number;
    amount: number;
  };

  const types: TxType[] = [
    'invoice',
    'chq',
    'cash',
    'momo',
    'rtn chq',
    'write-off',
    'discount',
    'tcc'
  ];

  let newTxs: newTx[] = $state([]);

  const today = new Date();
  function addTx() {
    newTxs.push({
      date: today.toISOString().substring(0, 10),
      type: 'invoice',
      narration: '',
      debit: 0,
      credit: 0,
      amount: 0
    });
  }

  let debit = $derived(newTxs.reduce((sum, { debit }) => sum + debit!, 0));
  let credit = $derived(newTxs.reduce((sum, { credit }) => sum + credit!, 0));
  let total = $derived(newTxs.reduce((sum, { debit, credit }) => sum + debit! - credit!, 0));

  function debitOrCreditTx(type: TxType) {
    if (type === 'invoice' || type === 'rtn chq') {
      return false;
    } else {
      return true;
    }
  }

  function submit() {
    let txs = newTxs.map((tx) => {
      let t = { ...tx };
      if (debitOrCreditTx(tx.type)) {
        t.amount = tx.credit! * -1;
      } else {
        t.amount = tx.debit!;
      }
      delete t.debit;
      delete t.credit;
      return t;
    });
    if (txs.some((tx) => tx.amount === 0)) {
      alert('New transactions amount are not valid.');
      return;
    }
    if (txs.some((tx) => tx.narration.length === 0)) {
      alert('New transactions has an "Empty" narration.');
      return;
    }
    addTxs(ledger.code, fin_year, txs);
  }
</script>

<section class="section pt-2">
  <div class="container">
    {#if ledgerStatus === 'idle'}
      <div>Idle</div>
    {:else if ledgerStatus === 'loading'}
      <div>Loading...</div>
    {:else if ledgerStatus === 'timedout'}
      <div>Request Timed Out</div>
    {:else if ledgerStatus === 'error'}
      <div>Error occurred: {appState.ledgers.error}</div>
    {:else if ledgerStatus === 'loaded' && ledger}
      <div class="columns is-vcentered">
        <div class="column is-four-fifths">
          <h3 class="title pb-2">{ledger.name}</h3>
          <div class="subtitle tags pb-2">
            <span class="tag">{ledger.code}</span>
            <span class="tag">{ledger.region}</span>
            <span class="tag">{ledger.is_gov ? 'GOV' : 'PVT'}</span>
            <span class="tag">{ledger.tags}</span>
          </div>
        </div>
        <div class="column">
          <div class="select is-primary is-focused level-right">
            <select
              name="fin_year"
              id="fin_year"
              bind:value={appState.fin_year}
              onchange={(e: HTMLChangeEvent) => goToLedger(ledger.code, e.target.value)}
            >
              {#each appState.books as book (book.id)}
                <option class="dropdown-item" value={book.fin_year}>{book.fin_year}</option>
              {/each}
            </select>
          </div>
        </div>
      </div>
      <h3 class="level mb-0">
        <div class="level-left"></div>
        <div class="level-right">
          <span class="subtitle is-3 mb-0">Opening Bal:</span>
          <span class="subtitle is-3">
            {ledger.op_bal === 0 ? '0.00' : moneyFmt(ledger.op_bal)}</span
          >
        </div>
      </h3>
      <button
        class="button is-danger is-outlined"
        onclick={() => deleteTxs(ledger!.code, fin_year, selectedTxs)}>Delete</button
      >
      <div class="overflow-x-auto">
        <table class="table is-fullwidth is-striped is-hoverable">
          <thead>
            <tr class="border-b border-gray-700" style="background-color: white;">
              <th><input type="checkbox" bind:checked={selectAll} /></th>
              <th>Date</th>
              <th class="hidden sm:table-cell">Type</th>
              <th class="has-text-left">Narration</th>
              <th class="has-text-right">Debit</th>
              <th class="has-text-right">Credit</th>
              <th class="has-text-right">Balance</th>
            </tr>
          </thead>
          <tbody>
            {#each ledger.txs as t (t.id)}
              <tr>
                <td class="has-text-center"><input type="checkbox" bind:checked={t.selected} /></td>
                <td class="has-text-center w-6">{dateFmt(new Date(t.date))}</td>
                <td class="has-text-center w-10 hidden sm:table-cell">{t.type}</td>
                <td class="has-text-left">{t.narration}</td>
                <td class="has-text-right">{moneyFmt(t.amount >= 0 ? t.amount : 0)}</td>
                <td class="has-text-right">{moneyFmt(t.amount < 0 ? Math.abs(t.amount) : 0)}</td>
                <td class="has-text-right">{moneyFmt(t.bal)}</td>
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr class="h-10">
              <th></th>
              <th></th>
              <th class="hidden sm:table-cell"></th>
              <th class="has-text-right">Total:</th>
              <th class="has-text-right">{moneyFmt(ledger.total_debit)}</th>
              <th class="has-text-right">{moneyFmt(Math.abs(ledger.total_credit))}</th>
              <th class="has-text-right">{moneyFmt(ledger.cl_bal)}</th>
            </tr>
          </tfoot>
        </table>
      </div>
    {/if}
  </div>
</section>
<section class="print:hidden">
  <div class="wrapper">
    {#if newTxs.length > 0}
      <div class="overflow-auto">
        <table class="table w-full is-bordered">
          <thead>
            <tr class="border-b border-gray-700">
              <th class="has-text-right max-w-5">#</th>
              <th class="w-5">Date</th>
              <th class="w-5">Type</th>
              <th class="has-text-left min-w-10">Narration</th>
              <th class="has-text-right min-w-32">Debit</th>
              <th class="has-text-right min-w-32">Credit</th>
              <th class="has-text-right w-5">Action</th>
            </tr>
          </thead>
          <tbody>
            {#each newTxs as t, i}
              <tr class="*:align-middle">
                <td class="text-right">{i + 1}</td>
                <td class="has-text-center"><input type="date" bind:value={t.date} /></td>
                <td>
                  <select
                    id="type"
                    bind:value={t.type}
                    class="pr-0"
                    onchange={() => {
                      t.debit = 0;
                      t.credit = 0;
                    }}
                  >
                    {#each types as v}
                      <option>{v}</option>
                    {/each}
                  </select>
                </td>
                <td class="has-text-left"><input class="w-full" bind:value={t.narration} /></td>
                <td class="min-w-32"
                  ><input
                    type="number"
                    bind:value={t.debit}
                    class="text-right w-full disabled:hidden"
                    disabled={debitOrCreditTx(t.type)}
                  /></td
                >
                <td class="min-w-32">
                  <input
                    type="number"
                    bind:value={t.credit}
                    class="has-text-right w-full disabled:hidden"
                    disabled={!debitOrCreditTx(t.type)}
                  /></td
                >
                <td>
                  <span class="flex justify-center items-baseline">
                    <button class="button mb-0" onclick={() => newTxs.splice(i, 1)}>-</button>
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr class="*:p-1">
              <th>
                <button class="button mt-1 mb-0" onclick={() => addTx()}>+</button>
              </th>
              <th></th>
              <th></th>
              <th>
                <button class="button is-primary mb-0" onclick={() => submit()}>Submit</button>
              </th>
              <th class="has-text-right">{moneyFmt(debit)}</th>
              <th class="has-text-right">{moneyFmt(credit)}</th>
              <th class="has-text-right">{moneyFmt(total)}</th>
            </tr>
          </tfoot>
        </table>
      </div>
    {:else}
      <div class="flex flex-row-reverse pr-2">
        <button class="button is-primary" onclick={() => addTx()}>+</button>
      </div>
    {/if}
  </div>
</section>
