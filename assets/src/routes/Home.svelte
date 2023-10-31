<script lang="ts">
  import { onMount } from 'svelte';
  import { state, getLedger, getLedgers } from '../store';
  import type { Ledger } from '../store';
  import { useSnapshot } from 'sveltio';
  import { moneyFmt } from '../utils';
  import Modal from '../lib/Modal.svelte';
  import Autocomplete from '../lib/Autocomplete.svelte';

  let isModalOpen = false;
  let text = '';
  let selected = null;

  $: if (text.length >= 2 && text.length <= 12) {
    console.log(text);
  }

  onMount(() => {
    getLedgers();
  });

  const snap = useSnapshot(state);

  function ledgerDetails(id: string) {
    isModalOpen = true;
    getLedger(id);
  }

  function handleSelect(e: { detail: Ledger }) {
    selected = e.detail;
    text = selected.name;
    console.log(e.detail);
  }
</script>

<section>
  <div class="wrapper">
    <Autocomplete
      id="customer"
      labelName="Filter Customers: "
      placeholder="Cash"
      bind:value={text}
      on:select={handleSelect}
      data={$snap.ledgers.data}
      let:item
    >
      <div class="flex flex-start px-4 py-2">
        <div class="flex-auto text-sm sm:overflow-x-auto">
          {item.name}
          <br />
          <small class="text-xs pt">
            <b>{item.code}</b>
            <b>{item.town_city}</b>
            <b>{item.region}</b>
            <b>{item.is_gov ? 'GOV' : 'PVT'}</b>
          </small>
        </div>
      </div>
    </Autocomplete>
  </div>
</section>
<section>
  <div class="wrapper">
    <div class="tabs">
      <ul class="flex-row-reverse" role="menu">
        {#each $snap.books as book (book.id)}
          <li title={book.period}>
            <a href={`\\app\\${book.id}`}>{book.fin_year}</a>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>
<section>
  <div class="wrapper">
    {#if $snap.ledgers.status === 'idle'}
      <div>Idle</div>
    {:else if $snap.ledgers.status === 'loading'}
      <div>Loading...</div>
    {:else if $snap.ledgers.status === 'timedout'}
      <div>Request Timed Out</div>
    {:else if $snap.ledgers.status === 'error'}
      <div>Error occurred: {$snap.ledgers.error}</div>
    {:else if $snap.ledgers.status === 'loaded'}
      <table class="table w-full is-bordered is-striped">
        <thead>
          <tr>
            <th>#</th>
            <th class="text-left">Name</th>
            <th>Code</th>
            <th>Region</th>
            <th class="text-right">Balance</th>
          </tr>
        </thead>
        <tbody>
          {#each $snap.ledgers.data as ledger, i (ledger.id)}
            <tr>
              <td class="text-center">{i + 1}</td>
              <td>{ledger.name}</td>
              <td class="text-center" on:click={() => ledgerDetails(ledger.id)}>{ledger.code}</td>
              <td class="text-center">{ledger.region}</td>
              <td class="text-right">{moneyFmt(ledger.op_bal)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>
</section>
<Modal open={isModalOpen} on:close={() => (isModalOpen = false)}>
  <section>
    <div class="wrapper flex items-center justify-center">
      {#if $snap.ledger}
        <table class="table">
          {#each Object.entries($snap.ledger) as [key, value]}
            <tr>
              <th class="text-right">{key}:</th>
              <td>{value}</td>
            </tr>
          {/each}
        </table>
      {/if}
    </div>
  </section>
</Modal>
