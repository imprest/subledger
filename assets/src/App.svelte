<script lang="ts">
  import { state } from './store';
  import { useSnapshot } from 'sveltio';
  import { path } from 'elegua';
  import Home from './routes/Home.svelte';
  import Analysis from './routes/Analysis.svelte';

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
  {#if $path === '/app' || $path === '/app/ledgers'}
    <Home />
  {:else if $path === '/app/analysis'}
    <Analysis />
  {:else}
    <div>Not Found</div>
  {/if}
</main>
