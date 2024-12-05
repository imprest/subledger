import { Socket, Presence } from 'phoenix';
import type { Book, Tx } from './types';
import { model } from './model.svelte';

class PhoenixChannel {
	socket = new Socket('/socket', { params: { token: window.userToken } });
	channel;
	presence;
	connected = $state(false);

	constructor() {
		this.socket = new Socket('/socket', { params: { token: window.userToken } });
		this.socket.connect();
		const org_id = 1;
		this.channel = this.socket.channel(`subledger:${org_id}`);
		this.channel
			.join()
			.receive('ok', () => {
				this.connected = true;
			})
			.receive('error', (resp) => {
				console.log('Unable to join', resp);
				this.connected = false;
			});

		this.channel.onError((resp) => {
			console.log('channel error: ', resp);
			this.connected = false;
		});

		this.presence = new Presence(this.channel);
	}

	async getBooks() {
		let { promise, resolve, reject } = Promise.withResolvers();

		if (model.books.length !== 0) {
			return resolve(0);
		}
		this.channel
			.push('books:get', {})
			.receive('ok', (msg: { books: Book[] }) => {
				model.books = msg.books;
				model.fin_year = msg.books[0].fin_year;
				resolve(0);
			})
			.receive('error', (msg: unknown) => {
				console.log('error', msg);
				reject();
			})
			.receive('timeout', () => {
				console.log('timeout');
				reject();
			});
		return promise;
	}

	async getLedgers(fin_year: number) {
		let { promise, resolve, reject } = Promise.withResolvers();

		this.channel
			.push('ledgers:get', { fin_year: fin_year })
			.receive('ok', (msg) => {
				model.ledgers = msg.ledgers;
				model.fin_year = fin_year;
				resolve(0);
			})
			.receive('error', (msg: string) => {
				reject(msg);
			})
			.receive('timeout', () => {
				reject('timedout');
			});
		return promise;
	}

	async getLedger(code: string, fin_year: number) {
		console.log('getLedger', code, fin_year);
		if (code === '') return;
		code = decodeURIComponent(code);
		let { promise, resolve, reject } = Promise.withResolvers();

		this.channel
			.push('ledger:get', { code: code, fin_year: fin_year })
			.receive('ok', (msg) => {
				model.ledger = msg.ledger;
				// if (model.ledger.txs) {
				// 	const ledger = msg.ledger;
				// 	ledger.txs = model.ledger.txs.map((x: Tx) => {
				// 		x.selected = false;
				// 		return x;
				// 	});
				// 	model.ledger = ledger;
				// } else {
				// 	model.ledger = msg.ledger;
				// }
				resolve(0);
			})
			.receive('error', (msg: string) => {
				reject(msg);
			})
			.receive('timeout', () => reject('timedout'));
		return promise;
	}

	async addTxs(code: string, fin_year: number, txs: object) {
		let { promise, resolve, reject } = Promise.withResolvers();
		this.channel
			.push('ledger:add_txs', { code: code, fin_year: fin_year, txs: txs })
			.receive('ok', (msg) => {
				model.ledger = msg.ledger;
				resolve(0);
			})
			.receive('error', (msg) => {
				reject(msg);
			})
			.receive('timeout', () => reject('Could not save. Server timeout'));
		return promise;
	}

	async deleteTxs(code: string, fin_year: number, txs: string[]) {
		let { promise, resolve, reject } = Promise.withResolvers();
		this.channel
			.push('ledger:delete_txs', { code: code, fin_year: fin_year, txs: txs })
			.receive('ok', (msg) => {
				const data = msg.ledger;
				data.txs = data.txs.map((x: Tx) => {
					x.selected = false;
					return x;
				});
				model.ledger = data;
				resolve(0);
			})
			.receive('error', (msg: string) => {
				reject(msg);
			})
			.receive('timeout', () => reject('timedout'));
		return promise;
	}
}

export const channel = new PhoenixChannel();
