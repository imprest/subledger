<script lang="ts">
  import { onMount } from 'svelte';
  import { state, getLedger, getLedgers } from '../store';
  import { useSnapshot } from 'sveltio';

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
    <table class="table w-full is-bordered is-striped">
      <thead>
        <tr>
          <th>#</th>
          <th class="text-left">Name</th>
          <th>Code</th>
          <th>Region</th>
          <th class="text-right">Balance</th>
          <th class="text-right">Credit Limit</th>
        </tr>
      </thead>
      <tbody>
        {#each $snap.ledgers as ledger, i (ledger.id)}
          <tr>
            <td class="text-center">{i + 1}</td>
            <td>{ledger.name}</td>
            <td class="text-center" on:click={() => getLedger(ledger.id)}>{ledger.code}</td>
            <td class="text-center">{ledger.region}</td>
            <td class="text-right">{ledger.op_bal}</td>
            <td class="text-right">{ledger.credit_limit}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</section>
