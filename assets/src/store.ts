import { Socket, Presence } from 'phoenix';
import { proxy } from 'valtio/vanilla';

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
  name: string;
  op_bal: number;
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

export function getLedger(id: string) {
  channel
    .push('ledger:get', { id: id })
    .receive('ok', (msg: Ledger) => (state.ledger = msg))
    .receive('error', (msg: unknown) => console.error(msg))
    .receive('timeout', () => console.log('timedout'));
}

export default socket;
