<script lang="ts">
  import Counter from './lib/Counter.svelte';
  import { state, getLedger } from './store';
  import { useSnapshot } from 'sveltio';

  const snap = useSnapshot(state);
</script>

<header class="border-gray-300 border-b">
  <nav>
    <div class="max-w-7xl mx-auto px-4 sm:px-2 lg:px-4">
      <div class="nav items-center">
        <div>
          <img class="h-8 w-8" src="/images/mgp.png" alt="MGP Logo" />
        </div>
        <div
          class="ml-4 min-w-0 flex items-baseline space-x-1 overflow-y-hidden overflow-x-auto scroller"
        >
          <a href="/app/ledgers">Ledgers</a>
          <a href="/app/analysis">Ledgers</a>
        </div>
      </div>
    </div>
  </nav>
</header>
<main>
  <section class="section">
    <div class="wrapper">
      <div class="tabs">
        <ul>
          <li class="bg-primary">Tab 1</li>
          <li class="bg-secondary">Tab 2</li>
          <li class="bg-error">Tab 3</li>
        </ul>
      </div>
      <div>
        <a href="https://vitejs.dev" target="_blank" rel="noreferrer"> Vite </a>
        <a href="https://svelte.dev" target="_blank" rel="noreferrer"> Svelte </a>
      </div>
      <h1>Vite + Svelte</h1>

      <div class="card text-lg">
        <Counter />
        <p>{$snap.connected}</p>
        <p class="bg-primary">{JSON.stringify($snap.ledger)}</p>
      </div>

      <button on:click={() => getLedger('1')}>Get Ledger</button>
    </div>
  </section>
  <section>
    <div class="wrapper">
      <p>
        Check out <a href="https://github.com/sveltejs/kit#readme" target="_blank" rel="noreferrer"
          >SvelteKit</a
        >, the official Svelte app framework powered by Vite!
      </p>

      <p class="read-the-docs">Click on the Vite and Svelte logos to learn more</p>
    </div>
  </section>
</main>

<style>
  .read-the-docs {
    color: #888;
  }
</style>
