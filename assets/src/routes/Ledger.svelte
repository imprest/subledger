<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger, type Ledger } from '../store.svelte';
  import { moneyFmt, dateFmt } from '../utils';

  let { ledger_id = '' } = $props();

  let ledger: Ledger = $derived(appState.ledger);
  $effect(() => {
    console.log(ledger);
  });
</script>

<h1>Ledger {ledger.id}</h1>

<section class="wrapper pt-2">
  <h1 class="title text-3xl">{ledger.name}</h1>
  <div class="tags">
    <span class="tag">{ledger.id}</span>
    <span class="tag">{ledger.region}</span>
    <span class="tag">{ledger.is_gov}</span>
    <span class="tag">{ledger.resp}</span>
  </div>
  <h1 class="text-right pb-3 pr-2">
    <span class="subtitle pr-2">Opening Bal:</span>
    <span class="title text-lg font-semibold"> {moneyFmt(ledger.op_bal)}</span>
  </h1>
  <table class="table w-full">
    <thead>
      <tr class="border-b border-gray-700" style="background-color: white;">
        <th class="text-left">ID</th>
        <th>Date</th>
        <th class="text-left">Description</th>
        <th class="text-right">Debit</th>
        <th class="text-right">Credit</th>
        <th class="text-right">Balance</th>
      </tr>
    </thead>
    <tbody>
      {#each ledger.txs as t (t.id)}
        <tr>
          <td>
            {#if t.id.startsWith('S')}
              {t.id}
            {:else}
              {t.id.substring(9, t.id.length)}
            {/if}
          </td>
          <td class="text-center">{dateFmt(t.date)}</td>
          <td class="text-right">{t.desc}</td>
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
        <th class="text-right">{moneyFmt(ledger.total_credit)}</th>
        <th class="text-right">{moneyFmt(ledger.total_bal)}</th>
      </tr>
      <tr></tr>
    </tbody>
  </table>
</section>
