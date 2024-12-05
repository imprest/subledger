declare global {
	interface Window {
		userToken?: string;
	}
}

export type Status = 'idle' | 'loading' | 'loaded' | 'error' | 'timedout';
export type Order = 'asc' | 'desc';

export type Book = {
	id: number;
	fin_year: number;
	period: string;
};

export type Ledger = {
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
};

export const txTypes = [
	'invoice',
	'chq',
	'cash',
	'momo',
	'rtn chq',
	'write-off',
	'refund',
	'discount',
	'tcc'
] as const;

export type TxType = (typeof txTypes)[number];

export type Tx = {
	id: string;
	ledger_id: string;
	date: string;
	type: TxType;
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
};

// not used e.g. Store<Ledgers[]> | Store<Ledger>
export type Store<T> = {
	status: Status;
	error: string;
	data?: T;
	updated_at?: Date;
	sortOrder?: Order;
	sortBy?: T extends any[] ? keyof any : keyof T;
};
