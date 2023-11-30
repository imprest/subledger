import { Router } from 'svelte-pilot';
import { getBooks } from './store';

export default new Router({
  base: '/app',
  routes: [
    {
      component: () => import('./App.svelte'),
      beforeEnter: () => getBooks(),
      children: [
        {
          path: '/',
          component: () => import('./routes/Home.svelte')
        },
        {
          path: '/ledgers',
          component: () => import('./routes/Home.svelte'),
          props: (route) => ({ book_id: route.query.string('fin_year') })
        },
        {
          path: '/ledgers/:id',
          component: () => import('./routes/Ledger.svelte'),
          props: (route) => ({ id: route.params.string('id') })
        },
        {
          path: '/analysis',
          component: () => import('./routes/Activity.svelte')
        }
      ]
    }
  ]
});
