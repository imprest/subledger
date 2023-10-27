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
          <th>ID</th>
          <th>Name</th>
          <th>Balance</th>
        </tr>
      </thead>
      <tbody>
        {#each $snap.ledgers as ledger (ledger.id)}
          <tr>
            <td on:click={() => getLedger(ledger.id)}>{ledger.id}</td>
            <td>{ledger.name}</td>
            <td>{ledger.op_bal}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</section>
