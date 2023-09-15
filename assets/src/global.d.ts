// Ensure this is treated as a module
export = {};

declare module '*.svelte' {
  import type { ComponentType } from 'svelte';
  const component: ComponentType;
  export default component;
}

declare global {
  interface Window {
    userToken?: string;
  }
  // eslint-disable-next-line @typescript-eslint/no-empty-interface
  interface document {}
}

declare module 'phoenix';
