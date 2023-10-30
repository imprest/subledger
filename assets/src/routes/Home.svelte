<script lang="ts">
  import { onMount } from 'svelte';
  import { state, getLedger, getLedgers } from '../store';
  import { useSnapshot } from 'sveltio';
  import { moneyFmt } from '../utils';

  onMount(() => {
    getLedgers();
  });

  const snap = useSnapshot(state);
</script>

<section>
  <div class="wrapper">
    <div class="card text-lg">
      <p class="bg-primary">{JSON.stringify($snap.ledger)}</p>
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
              <td class="text-center" on:click={() => getLedger(ledger.id)}>{ledger.code}</td>
              <td class="text-center">{ledger.region}</td>
              <td class="text-right">{moneyFmt(ledger.op_bal)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>
</section>
