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
    location: string;
  }
  // interface document {}
}

declare module 'phoenix';
