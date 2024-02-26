<svelte:options runes={true} />

<script context="module" lang="ts">
  let _routes = {};
  let props = {};
  const LoadRoute = (path: string) => {
    component = routes[path]();
  };

  export const navigate = (path) => {
    window.history.pushState(null, null, path);
    LoadRoute(path);
  };
  window.onpopstate = () => LoadRoute(location.pathname);
</script>

<script lang="ts">
  import Home from './routes/Home.svelte';
  import type { SvelteComponent } from 'svelte';
  let component: SvelteComponent;
  let { routes = { '/': Home } } = $props();
  console.log(routes);
  $effect(() => {
    LoadRoute(location.pathname);
  });
</script>

<svelte:component this={component} routes />
