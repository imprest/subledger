import { Socket, Presence } from 'phoenix';

const socket = new Socket('/socket', { params: { token: window.userToken } });
socket.connect();

export const channel = socket.channel('subledger:1', {});
channel
  .join()
  .receive('ok', (resp: unknown) => {
    connected();
    console.log('Joined successfully', resp);
  })
  .receive('error', (resp: unknown) => {
    disconnected();
    console.log('Unable to join', resp);
  });

channel.onError(() => {
  disconnected();
  console.log('closed');
});

export const presence = new Presence(channel);

type Order = 'asc' | 'desc';
type Status = 'idle' | 'loading' | 'loaded' | 'error' | 'timedout';
export type TxType =
  | 'invoice'
  | 'rtn chq'
  | 'write-off'
  | 'discount'
  | 'cash'
  | 'chq'
  | 'momo'
  | 'tcc';

export interface Store<T> {
  status: Status;
  error: string;
  data?: T;
  updated_at?: Date;
  sortOrder?: Order;
  // eslint-disable-next-line
  sortBy?: T extends any[] ? keyof any : keyof T;
}

export interface Tx {
  id: string;
  ledger_id: string;
  date: string;
  type: string;
  narration: string;
  amount: number;
  bal: number;
  text_colour: string;
  cell_colour: string;
  ref_id: string;
  note: string;
  inserted_by: string;
  updated_by: string;
  verified_by: string;
  inserted_at: string;
  updated_at: string;
  verified_at: string;
  selected: boolean;
}

export interface Ledger {
  id: string;
  code: string;
  name: string;
  op_bal: number;
  total_debit: number;
  total_credit: number;
  cl_bal: number;
  is_gov: boolean;
  is_active: boolean;
  tin: string;
  address_1: string;
  address_2: string;
  town_city: string;
  region: string;
  country_id: string;
  email: string;
  price_level: string;
  credit_limit: number;
  payment_terms: number;
  tags: string[];
  book_id: number;
  currency_id: string;
  txs: Tx[];
}

interface Book {
  id: number;
  fin_year: number;
  period: string;
}

export type appState = {
  connected: boolean;
  books: Book[];
  fin_year: number;
  ledgers: Store<Ledger[]>;
  ledger: Store<Ledger>;
};

export const ledgers = $state<Store<Ledger[]>>({
  status: 'idle',
  data: [],
  updated_at: undefined,
  sortOrder: 'asc',
  sortBy: 'name',
  error: ''
});

export const appState = $state<appState>({
  connected: false,
  books: [],
  fin_year: 0,
  ledgers: {
    status: 'idle',
    data: [],
    updated_at: undefined,
    sortOrder: 'asc',
    sortBy: 'name',
    error: ''
  },
  ledger: {
    status: 'idle',
    data: undefined,
    updated_at: undefined,
    error: ''
  }
});

export const connected = () => {
  appState.connected = true;
};
export const disconnected = () => {
  appState.connected = false;
};

export function getBooks() {
  if (appState.books.length > 0) return;
  channel
    .push('books:get', {})
    .receive('ok', (msg: { books: Book[] }) => {
      appState.books = msg.books;
      appState.fin_year = msg.books[0].fin_year;
    })
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export function getLedgers(fin_year: number) {
  if (appState.ledgers.status === 'loaded' && appState.fin_year === fin_year) return;
  appState.fin_year = fin_year;
  const ledgers = appState.ledgers;
  ledgers.status = 'loading';
  channel
    .push('ledgers:get', { fin_year: fin_year })
    .receive('ok', (msg) => {
      ledgers.status = 'loaded';
      ledgers.error = '';
      ledgers.data = msg.ledgers;
    })
    .receive('error', (msg: string) => {
      ledgers.status = 'error';
      ledgers.error = msg;
    })
    .receive('timeout', () => (ledgers.status = 'timedout'));
}

export function getLedger(code: string, fin_year: number) {
  // get('ledger', { code: code, fin_year: fin_year });
  appState.ledger.status = 'loading';
  channel
    .push('ledger:get', { code: code, fin_year: fin_year })
    .receive('ok', (msg) => {
      appState.ledger.status = 'loaded';
      appState.ledger.error = '';
      const ledger = msg.ledger;
      ledger.txs = ledger.txs.map((x: Tx) => {
        x.selected = false;
        return x;
      });
      appState.ledger.data = ledger;
    })
    .receive('error', (msg: string) => {
      appState.ledger.status = 'error';
      appState.ledger.error = msg;
    })
    .receive('timeout', () => (appState.ledger.status = 'timedout'));
}

export function deleteTxs(code: string, fin_year: number, txs: string[]) {
  const ledger = appState.ledger;
  channel
    .push('ledger:delete_txs', { code: code, fin_year: fin_year, txs: txs })
    .receive('ok', (msg) => {
      ledger.status = 'loaded';
      ledger.error = '';
      const data = msg.ledger;
      data.txs = data.txs.map((x: Tx) => {
        x.selected = false;
        return x;
      });
      ledger.data = data;
    })
    .receive('error', (msg: string) => {
      ledger.status = 'error';
      ledger.error = msg;
    })
    .receive('timeout', () => (ledger.status = 'timedout'));
}

export function addTxs(code: string, fin_year: number, txs: object) {
  channel
    .push('ledger:add_txs', { code: code, fin_year: fin_year, txs: txs })
    .receive('ok', (msg) => {
      appState.ledger.data = msg.ledger;
    })
    .receive('error', (msg) => {
      console.log(msg);
    })
    .receive('timeout', () => alert('Could not save. Server timeout'));
}

export default socket;
