<script lang="ts">
  import { appState } from './store.svelte';
  import { Link, View } from 'svelte-pilot';
</script>

{#if !appState.connected}
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
          <Link to="/">Ledgers</Link>
          <Link to="/analysis">Analysis</Link>
        </div>
        <div>Logout</div>
      </div>
    </div>
  </nav>
</header>
<main class="h-full pt-[calc(var(--header-height)+0.5rem)] print:pt-1">
  <View />
</main>
