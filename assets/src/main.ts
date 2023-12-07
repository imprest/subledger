import { ClientApp } from 'svelte-pilot';
import './app.css';
import router from './router';
import { createRoot } from 'svelte';

router.start(() =>
  createRoot(ClientApp, {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    target: document.getElementById('app') as HTMLElement,
    props: { router }
  })
);
