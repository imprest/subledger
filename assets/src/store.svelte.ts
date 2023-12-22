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
  book_id: string;
  currency_id: string;
  txs: Tx[];
}

interface Book {
  id: string;
  fin_year: number;
  period: string;
}

export type appState = {
  connected: boolean;
  books: Book[];
  book_id: string;
  ledgers: Store<Ledger[]>;
  ledger: Store<Ledger>;
};

export const appState = $state<appState>({
  connected: false,
  books: [],
  book_id: '_',
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
      appState.book_id = msg.books[0].id;
    })
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export function getLedgers(book_id: string) {
  if (appState.ledgers.status === 'loaded' && appState.book_id === book_id) return;

  appState.ledgers.status = 'loading';
  if (book_id !== '') {
    appState.book_id = book_id;
  }
  channel
    .push('ledgers:get', { book_id: book_id })
    .receive('ok', (msg: { ledgers: Ledger[] }) => {
      appState.ledgers.status = 'loaded';
      appState.ledgers.data = msg.ledgers;
    })
    .receive('error', (msg: string) => {
      appState.ledgers.status = 'error';
      appState.ledgers.error = msg;
    })
    .receive('timeout', () => (appState.ledgers.status = 'timedout'));
}

export function getLedger(id: string) {
  if (appState.ledger.status === 'loaded' && appState.ledger.data?.id === id) return;
  appState.ledger.status = 'loading';

  channel
    .push('ledger:get', { id: id })
    .receive('ok', (msg: { ledger: Ledger }) => {
      appState.ledger.status = 'loaded';
      appState.ledger.data = msg.ledger;
    })
    .receive('error', (msg: string) => {
      appState.ledger.status = 'error';
      appState.ledger.error = msg;
    })
    .receive('timeout', () => (appState.ledger.status = 'timedout'));
}

export function addTxs(txs) {
  channel
    .push('ledger:add_txs', { txs: txs, ledger_id: appState.ledger.data!.id })
    .receive('ok', (msg) => {
      console.log(msg);
    })
    .receive('error', (msg) => {
      console.log(msg);
    })
    .receive('timeout', () => alert('Could not save. Server timeout'));
}

export default socket;
