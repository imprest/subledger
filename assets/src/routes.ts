import Home from './routes/Home.svelte';
import Ledger from './routes/Ledger.svelte';
import Activity from './routes/Activity.svelte';
import { wrap } from 'svelte-spa-router/wrap';

export default {
  '/': wrap({ component: Home }),
  '/ledgers/:fin_year': Home,
  '/ledger/:code/:fin_year?': Ledger,
  '/activity': Activity,
  '*': Home
};

// export default new Router({
//   base: '/app',
//   routes: [
//     {
//       component: () => import('./App.svelte'),
//       beforeEnter: () => getBooks(),
//       children: [
//         {
//           path: '/',
//           component: () => import('./routes/Home.svelte')
//         },
//         {
//           path: '/ledgers',
//           component: () => import('./routes/Home.svelte'),
//           props: (route) => ({ book_id: route.query.number('fin_year') })
//         },
//         {
//           path: '/ledgers/:ledger_id',
//           component: () => import('./routes/Ledger.svelte'),
//           props: (route) => ({ id: route.params.number('ledger_id') })
//         },
//         {
//           path: '/analysis',
//           component: () => import('./routes/Activity.svelte')
//         }
//       ]
//     }
//   ]
// });
