<script lang="ts">
  import Counter from './lib/Counter.svelte';
  import { state, getLedger } from './store';
  import { subscribe, snapshot } from 'valtio/vanilla';
  import { onMount } from 'svelte';

  let snap = snapshot(state);

  onMount(() => {
    return subscribe(state, () => {
      snap = snapshot(state);
    });
  });
</script>

<main>
  <div>
    <a href="https://vitejs.dev" target="_blank" rel="noreferrer"> Vite </a>
    <a href="https://svelte.dev" target="_blank" rel="noreferrer"> Svelte </a>
  </div>
  <h1>Vite + Svelte</h1>

  <div class="card text-lg">
    <Counter />
    <p>{snap.connected}</p>
    <p>{JSON.stringify(snap.ledger)}</p>
  </div>

  <button on:click={() => getLedger('1')}>Get Ledger</button>
  <p>
    Check out <a href="https://github.com/sveltejs/kit#readme" target="_blank" rel="noreferrer"
      >SvelteKit</a
    >, the official Svelte app framework powered by Vite!
  </p>

  <p class="read-the-docs">Click on the Vite and Svelte logos to learn more</p>
</main>

<style>
  .read-the-docs {
    color: #888;
  }
</style>
