<script lang="ts">
  import { onMount } from 'svelte';
  import { state, getLedger, getLedgers } from '../store';
  import { useSnapshot } from 'sveltio';
  import { moneyFmt } from '../utils';
  import Modal from '../lib/Modal.svelte';

  let isModalOpen = false;

  onMount(() => {
    getLedgers();
  });

  const snap = useSnapshot(state);

  function ledgerDetails(id: string) {
    isModalOpen = true;
    getLedger(id);
  }
</script>

<section>
  <div class="wrapper">
    <div class="tabs">
      <ul class="flex-row-reverse">
        {#each $snap.books as book (book.id)}
          <li title={book.period} on:click={() => alert(book.id)}>
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
