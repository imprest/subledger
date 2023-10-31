<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let id = '';
  export let value = '';
  type T = $$Generic; /* eslint-disable-line no-undef */
  export let data: T[];
  export const className = '';
  export let placeholder = '';
  export let labelName = '';

  const dispatch = createEventDispatcher();
  const select = () => dispatch('select', data[counter]);
  let counter = 0;
  let isOpen = false;
  let div: HTMLElement;

  $: if (value && value.length == 0) {
    isOpen = false;
  }
  function keyCode(e: KeyboardEvent) {
    if (e.key === 'Tab') {
      isOpen = false;
      return;
    }
    if (e.key === 'ArrowDown') {
      counter == data.length - 1 ? (counter = 0) : (counter += 1);
      if (data.length > 0) isOpen = true;
      setScrollPosition(counter);
      return;
    }
    if (e.key === 'ArrowUp') {
      counter == 0 ? (counter = data.length - 1) : (counter -= 1);
      if (counter == data.length - 1) {
        div.scrollTop = 500;
      }
      if (data.length > 0) isOpen = true;
      setScrollPosition(counter);
      return;
    }
    if (e.key === 'Enter') {
      isOpen = false;
      select();
      return;
    }
    if (e.key === 'Escape') {
      e.preventDefault();
      isOpen = false;
      return;
    }
    value.length == 0 || data.length == 0 ? (isOpen = false) : (isOpen = true);
  }
  function setScrollPosition(index: number) {
    const element = div.querySelectorAll('a.dropdown-item:not(.is-disabled)')[index] as HTMLElement;
    if (!element) return;
    const visMin = div.scrollTop;
    const visMax = div.scrollTop + div.clientHeight - element.clientHeight;
    if (element.offsetTop < visMin) {
      div.scrollTop = element.offsetTop;
    } else if (element.offsetTop >= visMax) {
      div.scrollTop = element.offsetTop - div.clientHeight + element.clientHeight;
    }
  }
</script>

<div class="flex flex-grow items-center gap-1">
  <label for={id}>{labelName}</label>
  <div class="relative flex flex-grow">
    <input {id} on:keydown={keyCode} bind:value class="flex-grow" type="search" {placeholder} />
    <div
      class="block min-w-full max-w-full left-0 top-full pt-1 absolute z-20"
      class:hidden={isOpen != true}
    >
      <div class="overflow-auto max-h-52 bg-white rounded-md box-shadow" bind:this={div}>
        {#each data as item, i}
          <a
            href={`#${i}`}
            on:click|preventDefault={() => {
              counter = i;
              isOpen = false;
              select();
            }}
            on:mouseover={() => (counter = i)}
            on:focus={() => (counter = i)}
            class="dropdown-item whitespace-nowrap overflow-hidden overflow-ellipsis text-gray-700 block relative"
            class:is-hovered={i == counter}
          >
            <slot {item} />
          </a>
        {/each}
      </div>
    </div>
  </div>
</div>

<style>
  .is-hovered {
    background: #f5f5f5;
    color: #0a0a0a;
  }
  .box-shadow {
    box-shadow:
      0 2px 3px hsla(0, 0%, 4%, 0.1),
      0 0 0 1px hsla(0, 0%, 4%, 0.1);
  }
</style>
