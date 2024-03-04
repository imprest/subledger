<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger, addTxs, type TxType } from '../store.svelte';
  import { moneyFmt, dateFmt } from '../utils';

  type props = { params: { code: string; fin_year: string } };
  let { params } = $props<props>();

  let ledgerStatus = $derived(appState.ledger.status);

  let ledger = $derived(appState.ledger.data);

  $effect(() => {
    if (params) {
      let code = params.code;
      let year = parseInt(params.fin_year, 10);
      console.log(year);
      if (year) {
        getLedger(code, year);
      } else {
        getLedger(code, 0);
      }
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
    addTxs(txs);
  }
</script>

<section>
  <div class="wrapper">
    {#if ledgerStatus === 'idle'}
      <div>Idle</div>
    {:else if ledgerStatus === 'loading'}
      <div>Loading...</div>
    {:else if ledgerStatus === 'timedout'}
      <div>Request Timed Out</div>
    {:else if ledgerStatus === 'error'}
      <div>Error occurred: {appState.ledgers.error}</div>
    {:else if ledgerStatus === 'loaded' && ledger}
      <h3 class="title text-3xl">{ledger.name}</h3>
      <div class="tags">
        <span class="tag">{ledger.code}</span>
        <span class="tag">{ledger.region}</span>
        <span class="tag">{ledger.is_gov ? 'GOV' : 'PVT'}</span>
        <span class="tag">{ledger.tags}</span>
      </div>
      <h3 class="text-right pb-5">
        <span class="subtitle pr-2">Opening Bal:</span>
        <span class="title text-lg font-semibold pr-2 ml-20">
          {ledger.op_bal === 0 ? '0.00' : moneyFmt(ledger.op_bal)}</span
        >
      </h3>
      <div class="overflow-x-auto">
        <table class="table w-full table-auto is-striped is-hoverable">
          <thead>
            <tr class="border-b border-gray-700" style="background-color: white;">
              <th>Date</th>
              <th class="hidden sm:table-cell">Type</th>
              <th class="text-left">Narration</th>
              <th class="text-right">Debit</th>
              <th class="text-right">Credit</th>
              <th class="text-right">Balance</th>
            </tr>
          </thead>
          <tbody>
            {#each ledger.txs as t (t.id)}
              <tr>
                <td class="text-center w-6">{dateFmt(new Date(t.date))}</td>
                <td class="text-center w-10 hidden sm:table-cell">{t.type}</td>
                <td class="text-left">{t.narration}</td>
                <td class="text-right">{moneyFmt(t.amount >= 0 ? t.amount : 0)}</td>
                <td class="text-right">{moneyFmt(t.amount < 0 ? Math.abs(t.amount) : 0)}</td>
                <td class="text-right">{moneyFmt(t.bal)}</td>
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr class="h-10">
              <th></th>
              <th class="hidden sm:table-cell"></th>
              <th class="text-right">Total:</th>
              <th class="text-right">{moneyFmt(ledger.total_debit)}</th>
              <th class="text-right">{moneyFmt(Math.abs(ledger.total_credit))}</th>
              <th class="text-right">{moneyFmt(ledger.cl_bal)}</th>
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
              <th class="text-right max-w-5">#</th>
              <th class="w-5">Date</th>
              <th class="w-5">Type</th>
              <th class="text-left min-w-10">Narration</th>
              <th class="text-right min-w-10">Debit</th>
              <th class="text-right min-w-10">Credit</th>
              <th class="text-right w-5">Action</th>
            </tr>
          </thead>
          <tbody>
            {#each newTxs as t, i}
              <tr class="*:align-middle">
                <td class="text-right">{i + 1}</td>
                <td class="text-center"><input type="date" value={t.date} /></td>
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
                <td class="text-left"><input class="w-full" bind:value={t.narration} /></td>
                <td
                  ><input
                    bind:value={t.debit}
                    class="text-right w-full disabled:hidden"
                    disabled={debitOrCreditTx(t.type)}
                  /></td
                >
                <td>
                  <input
                    bind:value={t.credit}
                    class="text-right w-full disabled:hidden"
                    disabled={!debitOrCreditTx(t.type)}
                  /></td
                >
                <td>
                  <span>
                    <button
                      class="btn rounded-full px-2 mt-1 mb-0"
                      onclick={() => newTxs.splice(i, 1)}>-</button
                    >
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr class="*:p-1">
              <th>
                <button class="btn rounded-full px-2 mt-1 mb-0" onclick={() => addTx()}>+</button>
              </th>
              <th></th>
              <th></th>
              <th>
                <button class="btn btn-primary mb-0" onclick={() => submit()}>Submit</button>
              </th>
              <th class="text-right">{moneyFmt(debit)}</th>
              <th class="text-right">{moneyFmt(credit)}</th>
              <th class="text-right">{moneyFmt(total)}</th>
            </tr>
          </tfoot>
        </table>
      </div>
    {:else}
      <div class="flex flex-row-reverse pr-2">
        <button class="btn btn-primary" onclick={() => addTx()}>+</button>
      </div>
    {/if}
  </div>
</section>
