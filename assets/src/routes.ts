import Home from './routes/Home.svelte';
import Ledger from './routes/Ledger.svelte';
import Activity from './routes/Activity.svelte';

export default {
  '/': Home,
  '/ledgers/:fin_year': Home,
  '/ledger/:code/:fin_year?': Ledger,
  '/activity': Activity,
  '*': Home
};
