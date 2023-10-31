<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { X } from 'lucide-svelte';

  const dispatch = createEventDispatcher();

  export let open = false;

  function close() {
    dispatch('close');
  }

  function keydown(e: KeyboardEvent) {
    if (open && e.key === 'Escape') {
      close();
    }
  }
</script>

<svelte:window on:keydown={keydown} />
<div
  class="absolute flex flex-col inset-0 items-center justify-center overflow-hidden z-40 min-h-full min-w-full"
  class:hidden={!open}
>
  <div role="presentation" class="absolute inset-0 bg-gray-700 opacity-90" on:click={close}></div>
  <div class="bg-white relative mx-5 overflow-auto w-full md:max-w-3xl py-2 px-4">
    <slot />
  </div>
  <button on:click={close} class="fixed top-5 right-5 text-white z-50" aria-label="close">
    <X />
  </button>
</div>
