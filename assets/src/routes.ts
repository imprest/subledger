import Home from './routes/Home.svelte';
import Ledger from './routes/Ledger.svelte';
import Activity from './routes/Activity.svelte';

export default {
  '/app': Home,
  '/app/ledgers/:fin_year': Home,
  '/app/ledger/:code/:fin_year?': Ledger,
  '/app/activity': Activity,
  '*': Home
};
