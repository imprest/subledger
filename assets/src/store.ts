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

type Ledger = {
  id: string;
  code: string;
  name: string;
  op_bal: number;
  is_gov: boolean;
  is_active: boolean;
  tin: string;
  address_1: string;
  address_2: string;
  town_or_city: string;
  region: string;
  country_id: string;
  email: string;
  price_level: string;
  credit_limit: number;
  payment_terms: number;
  tags: string[];
  book_id: string;
  currency_id: string;
};

export type State = {
  connected: boolean;
  ledgers: Ledger[];
  ledger?: Ledger;
};

export const state = proxy<State>({
  connected: false,
  ledgers: [],
  ledger: undefined
});

export const connected = () => {
  state.connected = true;
};
export const disconnected = () => {
  state.connected = false;
};

export function getLedgers() {
  channel
    .push('ledgers:get', {})
    .receive('ok', (msg: { ledgers: Ledger[] }) => {
      state.ledgers = msg.ledgers;
    })
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export function getLedger(id: string) {
  channel
    .push('ledger:get', { id: id })
    .receive('ok', (msg: { ledger: Ledger }) => (state.ledger = msg.ledger))
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export default socket;
