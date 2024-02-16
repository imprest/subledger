import Home from './routes/Home.svelte';
import Ledger from './routes/Ledger.svelte';
import Activity from './routes/Activity.svelte';

export default {
  '/': Home,
  '/ledger/:ledger_id': Ledger,
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
