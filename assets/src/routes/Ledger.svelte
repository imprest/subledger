<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger, type Tx } from '../store.svelte';
  import { moneyFmt, dateFmt } from '../utils';

  let { id = '' } = $props();

  let ledgerStatus = $derived(appState.ledger.status);

  let ledger = $derived(appState.ledger.data);

  $effect.pre(() => {
    getLedger(id);
  });

  let newTxs = $state([]);

  function addTx() {
    newTxs.push({ date: '2023-12-12', type: 'invoice', narration: '', debit: 0.0, credit: 0.0 });
  }

  let debit = $derived(newTxs.reduce((sum, { debit }) => sum + debit, 0));
  let credit = $derived(newTxs.reduce((sum, { credit }) => sum + credit, 0));
  let total = $derived(newTxs.reduce((sum, { debit, credit }) => sum + debit - credit, 0));
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
        <table class="table w-full is-striped">
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
                <td class="text-center">{dateFmt(new Date(t.date))}</td>
                <td class="text-center hidden sm:table-cell">{t.type}</td>
                <td class="text-left">{t.narration}</td>
                <td class="text-right">{moneyFmt(t.amount >= 0 ? t.amount : 0)}</td>
                <td class="text-right">{moneyFmt(t.amount < 0 ? Math.abs(t.amount) : 0)}</td>
                <td class="text-right">{moneyFmt(t.bal)}</td>
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr>
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
    <div class="flex flex-row-reverse pr-2">
      <button class="btn btn-primary" onclick={() => addTx()}>+</button>
    </div>
    {#if newTxs.length > 0}
      <div class="overflow-x-auto">
        <table class="table is-striped">
          <thead>
            <tr class="border-b border-gray-700" style="background-color: white;">
              <th class="text-right">#</th>
              <th>Date</th>
              <th>Type</th>
              <th class="text-left">Narration</th>
              <th class="text-right">Debit</th>
              <th class="text-right">Credit</th>
              <th class="text-right">Balance</th>
            </tr>
          </thead>
          <tbody>
            {#each newTxs as t, i}
              <tr>
                <td class="text-right">{i + 1}</td>
                <td class="text-center"><input type="date" value={t.date} /></td>
                <td><input value={t.type} /></td>
                <td class="text-left"><input value={t.narration} /></td>
                <td><input type="number" bind:value={t.debit} class="text-right" step="0.01" /></td>
                <td><input type="number" bind:value={t.credit} class="text-right" step="0.01" /></td
                >
                <td><button class="btn btn-error" onclick={() => newTxs.splice(i, 1)}>-</button></td
                >
              </tr>
            {/each}
          </tbody>
          <tfoot class="border-b border-t border-gray-700">
            <tr>
              <th></th>
              <th></th>
              <th></th>
              <th></th>
              <th class="text-right">{moneyFmt(debit)}</th>
              <th class="text-right">{moneyFmt(credit)}</th>
              <th class="text-right">{moneyFmt(total)}</th>
            </tr>
          </tfoot>
        </table>
        <button class="sumbit btn btn-primary">Submit</button>
        <button class="sumbit btn">Clear</button>
      </div>
    {/if}
  </div>
</section>
