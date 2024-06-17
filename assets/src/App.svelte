<svelte:options runes={true} />

<script lang="ts">
  import { appState, getBooks } from './store.svelte';
  import Router from 'svelte-spa-router';
  import routes from './routes';
  import { untrack } from 'svelte';

  let booksLoaded = $derived(appState.books.length > 0);
  let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute('content');
  $effect.pre(() => {
    untrack(() => getBooks());
  });
</script>

{#if !appState.connected}
  <div title="In Off-line mode" class="fixed bottom-0 right-3 text-red-600 text-4xl cursor-pointer">
    •
  </div>
{/if}
<header>
  <nav class="navbar is-fixed-top has-shadow" aria-label="main navigation">
    <div class="navbar-brand">
      <div class="navbar-item">
        <img width="50px" height="500px" src="/images/logo.svg" alt="Logo" />
      </div>

      <button
        class="navbar-burger"
        aria-label="menu"
        aria-expanded="false"
        data-target="navbarBasicExample"
      >
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
      </button>
    </div>
    <div id="navbarBasicExample" class="navbar-menu">
      <div class="navbar-start">
        <a href="#/" class="navbar-item">Ledgers</a>
        <a href="#/activity" class="navbar-item">Activity</a>
      </div>

      <div class="navbar-end">
        <div class="navbar-item">
          <div class="buttons">
            <a
              data-csrf={csrfToken}
              data-method="delete"
              data-to="/users/log_out"
              href="/users/log_out">Logout</a
            >
          </div>
        </div>
      </div>
    </div>
    <div class="max-w-7xl mx-auto px-4 sm:px-2 lg:px-4">
      <div class="flex items-center">
        <div></div>
        <div
          class="ml-4 min-w-0 flex item-baseline space-x-1 overflow-y-hidden overflow-x-auto scroller grow"
        ></div>
        <div class="p-2 print:hidden"></div>
      </div>
    </div>
  </nav>
</header>
<main>
  {#if booksLoaded}
    <Router {routes} />
  {:else}
    <div>Initialising App...</div>
  {/if}
</main>
