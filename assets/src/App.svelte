<svelte:options runes={true} />

<script lang="ts">
  import Home from './routes/Home.svelte';
  import { appState, getBooks } from './store.svelte';
  import Router from 'svelte-spa-router';
  import routes from './routes';

  let booksLoaded = $derived(appState.books.length > 0);
  let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute('content');
  $effect.pre(() => {
    getBooks();
  });
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
          <a href="/" class="m-1 px-1">Ledgers</a>
          <a href="/activity" class="m-1 px-1">Activity</a>
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
  {#if booksLoaded}
    <Router {routes} />
  {:else}
    <div>Hello</div>
  {/if}
</main>
