<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger } from '../store.svelte';
  import { moneyFmt, dateFmt } from '../utils';

  let { id = '' } = $props();

  let ledgerStatus = $derived(appState.ledger.status);

  let ledger = $derived(appState.ledger.data);

  $effect.pre(() => {
    getLedger(id);
  });
</script>

<section class="wrapper pt-2">
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
      <h3 class="text-right pb-3 pr-2">
        <span class="subtitle pr-2">Opening Bal:</span>
        <span class="title text-lg font-semibold"> {moneyFmt(ledger.op_bal)}</span>
      </h3>
      <div class="overflow-x-auto">
        <table class="table w-full is-striped">
          <thead>
            <tr class="border-b border-gray-700" style="background-color: white;">
              <th>Date</th>
              <th>Type</th>
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
                <td class="text-center">{t.type}</td>
                <td class="text-left">{t.narration}</td>
                <td class="text-right">{moneyFmt(t.debit)}</td>
                <td class="text-right">{moneyFmt(t.credit)}</td>
                <td class="text-right">{moneyFmt(t.bal)}</td>
              </tr>
            {/each}
            <tr class="border-b border-t border-gray-700">
              <th></th>
              <th></th>
              <th class="text-right">Total:</th>
              <th class="text-right">{moneyFmt(ledger.total_debit)}</th>
              <th class="text-right">{moneyFmt(Math.abs(ledger.total_credit))}</th>
              <th class="text-right">{moneyFmt(ledger.cl_bal)}</th>
            </tr>
            <tr></tr>
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</section>
