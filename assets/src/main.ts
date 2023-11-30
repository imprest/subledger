import { ClientApp } from 'svelte-pilot';
import './app.postcss';
import router from './router';

router.start(
  () =>
    new ClientApp({
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      target: document.getElementById('app') as HTMLElement,
      props: { router }
    })
);
