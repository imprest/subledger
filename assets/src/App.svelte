<script lang="ts">
  import { onMount } from 'svelte';
  import Counter from './lib/Counter.svelte';
  import { state, getLedger, getLedgers } from './store';
  import { useSnapshot } from 'sveltio';

  onMount(() => {
    getLedgers();
  });

  const snap = useSnapshot(state);
</script>

{#if !$snap.connected}
  <div title="In Off-line mode" class="fixed bottom-0 right-3 text-red-700 text-3xl cursor-pointer">
    •
  </div>
{/if}
<header
  class="header print:relative fixed top-0 left-0 z-30 border-b border-gray-300 w-full bg-white h-[--header-height]"
>
  <nav>
    <div class="max-w-7xl mx-auto px-4 sm:px-2 lg:px-4">
      <div class="items-center flex">
        <div>
          <img class="h-8 w-8" src="/images/logo.svg" alt="Logo" />
        </div>
        <div
          class="ml-4 min-w-0 flex items-baseline space-x-1 overflow-y-hidden overflow-x-auto scroller grow"
        >
          <a class="pr-2 py-2" href="/app/ledgers">Ledgers</a>
          <a class="pr-2 py-2" href="/app/analysis">Analysis</a>
        </div>
        <div>Logout</div>
      </div>
    </div>
  </nav>
</header>
<main class="h-full mt-[--header-height] print:mt-1">
  <section>
    <div class="wrapper">
      <div class="tabs">
        <ul>
          <li class="bg-primary is-active"><a href="#tab1">Tab 1</a></li>
          <li class="bg-secondary"><a href="#tab2">Tab 2</a></li>
          <li class="bg-error"><a href="#tab3">Tab 3</a></li>
        </ul>
      </div>
      <div>
        <a href="https://vitejs.dev" target="_blank" rel="noreferrer"> Vite </a>
        <a href="https://svelte.dev" target="_blank" rel="noreferrer"> Svelte </a>
      </div>

      <div class="card text-lg">
        <Counter />
        <p class="bg-primary">{JSON.stringify($snap.ledger)}</p>
      </div>

      <button on:click={() => getLedger('1')}>Get Ledger</button>
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
              <td>{ledger.id}</td>
              <td>{ledger.name}</td>
              <td>{ledger.op_bal}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </section>
</main>
