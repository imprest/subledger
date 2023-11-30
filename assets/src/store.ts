import { Socket, Presence } from 'phoenix';
import { proxy } from 'sveltio';

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

export interface Store<T> {
  status: Status;
  error: string;
  data: T;
  updated_at?: Date;
  sortOrder?: Order;
  // eslint-disable-next-line
  sortBy?: T extends any[] ? keyof any : keyof T;
}

export interface Ledger {
  id: string;
  code: string;
  name: string;
  op_bal: number;
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
}

interface Book {
  id: string;
  fin_year: number;
  period: string;
}

export type State = {
  connected: boolean;
  books: Book[];
  book_id: string;
  ledgers: Store<Ledger[]>;
  ledger?: Ledger;
};

export const state = proxy<State>({
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
  ledger: undefined
});

export const connected = () => {
  state.connected = true;
};
export const disconnected = () => {
  state.connected = false;
};

export function getBooks() {
  if (state.books.length > 0) return;
  channel
    .push('books:get', {})
    .receive('ok', (msg: { books: Book[] }) => {
      state.books = msg.books;
      state.book_id = msg.books[0].id;
    })
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export function getLedgers(book_id: string) {
  if (state.ledgers.status === 'loaded' && state.book_id === book_id) return;

  state.ledgers.status = 'loading';
  if (book_id !== '') {
    state.book_id = book_id;
  }
  channel
    .push('ledgers:get', { book_id: book_id })
    .receive('ok', (msg: { ledgers: Ledger[] }) => {
      state.ledgers.status = 'loaded';
      state.ledgers.data = msg.ledgers;
    })
    .receive('error', (msg: string) => {
      state.ledgers.status = 'error';
      state.ledgers.error = msg;
    })
    .receive('timeout', () => (state.ledgers.status = 'timedout'));
}

export function getLedger(id: string) {
  channel
    .push('ledger:get', { id: id })
    .receive('ok', (msg: { ledger: Ledger }) => (state.ledger = msg.ledger))
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export default socket;
