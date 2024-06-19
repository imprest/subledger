<script lang="ts">
  import type { Snippet } from 'svelte';
  let { open, children }: { open: boolean; children: Snippet } = $props();

  let isOpen = $state(false);

  function close() {
    isOpen = false;
  }

  function keydown(e: KeyboardEvent) {
    if (open && e.key === 'Escape') {
      isOpen = false;
    }
  }
</script>

<svelte:window onkeydown={keydown} />
<div class="modal" class:is-active={!isOpen}>
  <div class="modal-background"></div>
  <div class="modal-content">
    {#if children}
      {@render children()}
    {/if}
  </div>
  <button onclick={close} class="modal-close is-large" aria-label="close"></button>
</div>
