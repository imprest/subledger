<svelte:options runes={true} />

<script lang="ts">
  import type { SvelteComponent } from 'svelte';
  let component: SvelteComponent = $state(undefined);
  let { routes = {} } = $props<{ routes: object }>();

  $effect(() => {
    LoadRoute(location.pathname);
  });

  const LoadRoute = (path: string): void => {
    component = routes[path]();
  };

  export const navigate = (path: string) => {
    window.history.pushState(null, '', path);
    LoadRoute(path);
  };
  window.onpopstate = () => LoadRoute(location.pathname);
</script>

<svelte:component this={component} />
