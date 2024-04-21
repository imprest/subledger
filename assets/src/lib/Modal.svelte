<script lang="ts">
  let { open = false, children }: { open: boolean } = $props();

  function close() {
    open = false;
  }

  function keydown(e: KeyboardEvent) {
    if (open && e.key === 'Escape') {
      close();
    }
  }
</script>

<svelte:window onkeydown={keydown} />
<div
  class="fixed flex flex-col inset-0 items-center justify-center overflow-hidden z-40 min-h-full min-w-full"
  class:hidden={!open}
>
  <div role="presentation" class="absolute inset-0 bg-gray-700 opacity-90" onclick={close}></div>
  <div class="bg-white relative mx-5 overflow-auto w-full md:max-w-3xl py-2 px-4">
    {#if children}
      {@render children()}
    {/if}
  </div>
  <button onclick={close} class="fixed top-5 right-5 text-white z-50" aria-label="close">
    X
  </button>
</div>
