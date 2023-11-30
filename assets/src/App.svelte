<script lang="ts">
  import { state } from './store';
  import { useSnapshot } from 'sveltio';
  import { path, resolve, params } from 'elegua';
  import Home from './routes/Home.svelte';
  import Activity from './routes/Activity.svelte';
  import Ledger from './routes/Ledger.svelte';

  const snap = useSnapshot(state);
</script>

{#if !$snap.connected}
  <div title="In Off-line mode" class="fixed bottom-0 right-3 text-red-600 text-4xl cursor-pointer">
    •
  </div>
{/if}
<header
  class="header print:relative fixed top-0 left-0 z-30 border-b border-gray-300 w-full bg-white h-[--header-height]"
>
  <nav>
    <div class="max-w-7xl mx-auto px-4 sm:px-2 lg:px-4">
      <div class="flex items-baseline">
        <div>
          <img class="h-8 w-8" src="/images/logo.svg" alt="Logo" />
        </div>
        <div class="p-1 min-w-0 flex space-x-1 overflow-y-hidden overflow-x-auto scroller grow">
          <a
            class="p-2"
            href="/app/ledgers"
            class:selected={$path === '/app' || $path === '/app/ledgers'}>Ledgers</a
          >
          <a class="p-2" href="/app/analysis" class:selected={$path === '/app/analysis'}>Analysis</a
          >
        </div>
        <div>Logout</div>
      </div>
    </div>
  </nav>
</header>
<main class="h-full pt-[calc(var(--header-height)+0.5rem)] print:pt-1">
  {#if $path === '/app' || $path === '/app/ledgers'}
    <Home />
  {:else if resolve($path, '/app/ledgers/:book_id')}
    <Home book_id={$params['book_id']} />
  {:else if resolve($path, '/app/ledger/:id')}
    <Ledger id={$params['id']} />
  {:else if $path === '/app/activity'}
    <Activity />
  {:else}
    <div>Not Found</div>
  {/if}
</main>

<style>
  .selected {
    font-weight: bold;
  }
</style>
