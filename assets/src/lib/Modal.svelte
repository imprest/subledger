<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  export let open = false;

  function close() {
    dispatch('close');
  }
</script>

<div
  class="fixed flex flex-col inset-0 items-center justify-center overflow-hidden z-40 min-h-full min-w-full backdrop-filter backdrop-sepia"
  class:hidden={!open}
>
  <div class="fixed inset-0 bg-gray-700 opacity-90" on:click={close}></div>
  <div class="bg-white relative mx-5 overscroll-auto w-full md:max-w-3xl py-2 px-4">
    <slot />
  </div>
  <button on:click={close} class="fixed top-5 right-5 text-white z-50" aria-label="close">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="h-10 w-10"
      viewBox="0 0 20 20"
      fill="currentColor"
    >
      <path
        fill-rule="evenodd"
        d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
        clip-rule="evenodd"
      />
    </svg></button
  >
</div>
