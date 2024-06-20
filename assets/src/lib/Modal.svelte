<script lang="ts">
  import type { Snippet } from 'svelte';
  let { open = $bindable(), children }: { open: boolean; children: Snippet } = $props();

  function close() {
    open = false;
  }

  function keydown(e: KeyboardEvent) {
    if (open && e.key === 'Escape') {
      open = false;
    }
  }
</script>

<svelte:window onkeydown={keydown} />
<div class="modal" class:is-active={open}>
  <button class="modal-background" onclick={close} aria-label="close"></button>
  <div class="modal-content">
    {#if children}
      {@render children()}
    {/if}
  </div>
  <button onclick={close} class="modal-close is-large" aria-label="close"></button>
</div>
