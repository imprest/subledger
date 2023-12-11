<script lang="ts">
  import { appState } from './store.svelte';
  import { Link, View } from 'svelte-pilot';

  let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute('content');
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
      <div class="flex items-center">
        <div>
          <img class="h-8 w-8" src="/images/logo.svg" alt="Logo" />
        </div>
        <div
          class="ml-4 min-w-0 flex item-baseline space-x-1 overflow-y-hidden overflow-x-auto scroller grow"
        >
          <Link to="/" class="m-1 px-1">Ledgers</Link>
          <Link to="/analysis" class="m-1 px-1">Analysis</Link>
        </div>
        <div class="p-2 print:hidden">
          <a
            data-csrf={csrfToken}
            data-method="delete"
            data-to="/users/log_out"
            href="/users/log_out">Logout</a
          >
        </div>
      </div>
    </div>
  </nav>
</header>
<main class="h-full pt-[calc(var(--header-height)+0.25rem)] print:pt-1">
  <View />
</main>
