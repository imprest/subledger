<script lang="ts">
	import { moneyFmt, dateFmt } from '../utils';
	import type { Tx, TxType } from '../types.ts';
	import { model } from '../model.svelte';
	import { channel } from '../service.svelte';
	import { txTypes } from '../types';
	import { untrack } from 'svelte';

	type MyProps = { params: { code: string; fin_year: string } };
	let { params }: MyProps = $props();

	let code = $state('');
	let fin_year = $state(model.books[0].fin_year);

	// On mount determine which ledger and fin_year to load
	$effect(() => {
		code = params.code;
		const year = Number.parseInt(params.fin_year);
		if (model.finYearExists(year)) {
			fin_year = year;
		}
	});

	let selectedTxs = $derived(model.ledger!.txs.filter((x: Tx) => x.selected).map((x) => x.id));
	let selectAll = $state(false);
	$effect(() => {
		selectAll;
		if (model.ledger !== undefined && model.ledger.txs.length > 0) {
			untrack(() => {
				model.ledger!.txs.map((tx) => (tx.selected = selectAll));
			});
		}
	});

	type newTx = {
		date: string;
		type: TxType;
		narration: string;
		debit?: number;
		credit?: number;
		amount: number;
	};

	const types = $derived(txTypes);

	let newTxs: newTx[] = $state([]);

	const today = new Date();
	function addTx() {
		newTxs.push({
			date: today.toISOString().substring(0, 10),
			type: 'invoice',
			narration: '',
			debit: 0,
			credit: 0,
			amount: 0
		});
	}

	let debit = $derived(newTxs.reduce((sum, { debit }) => sum + debit!, 0));
	let credit = $derived(newTxs.reduce((sum, { credit }) => sum + credit!, 0));
	let total = $derived(newTxs.reduce((sum, { debit, credit }) => sum + debit! - credit!, 0));

	function debitOrCreditTx(type: TxType) {
		if (type === 'invoice' || type === 'rtn chq') {
			return false;
		} else {
			return true;
		}
	}

	function submit() {
		let txs = newTxs.map((tx) => {
			let t = { ...tx };
			if (debitOrCreditTx(tx.type)) {
				t.amount = tx.credit! * -1;
			} else {
				t.amount = tx.debit!;
			}
			delete t.debit;
			delete t.credit;
			return t;
		});
		if (txs.some((tx) => tx.amount === 0)) {
			alert('New transactions amount are not valid.');
			return;
		}
		if (txs.some((tx) => tx.narration.length === 0)) {
			alert('New transactions has an "Empty" narration.');
			return;
		}

		channel.addTxs(model.ledger.code, fin_year, txs);
	}
</script>

{#await channel.getLedger(code, fin_year)}
	<p>Loading...</p>
{:then}
	<section class="section">
		<div class="flex flex-row items-start">
			<div class="grow">
				<h3 class="mb-1">{model.ledger.name}</h3>
				<div class="tags gap-2">
					<span>{model.ledger.code}</span>
					<span>{model.ledger.region}</span>
					<span>{model.ledger.is_gov ? 'GOV' : 'PVT'}</span>
					<span>{model.ledger.tags}</span>
				</div>
			</div>

			<div class="select-combo">
				<label for="book">Year</label>
				<select id="book" bind:value={fin_year}>
					{#each model.books as book}
						<option>{book.fin_year}</option>
					{/each}
				</select>
			</div>
		</div>
		<div class="flex">
			<div class="grow"></div>
			<h4>
				<span class="font-normal">Opening Balance:&nbsp;</span>
				{model.ledger.op_bal >= 0 ? 'Dr' : 'Cr'}
				{model.ledger.op_bal === 0 ? '0.00' : moneyFmt(model.ledger.op_bal)}
			</h4>
		</div>
		<button class="btn" onclick={() => channel.deleteTxs(model.ledger.code, fin_year, selectedTxs)}
			>Delete</button
		>
	</section>
	<section class="section">
		<div class="overflow-x-auto">
			<table class="table w-full is-fullwidth is-striped is-hoverable">
				<thead>
					<tr class="border-b border-gray-700" style="background-color: white;">
						<th class="print:hidden"><input type="checkbox" bind:checked={selectAll} /></th>
						<th>Date</th>
						<th class="hidden sm:table-cell">Type</th>
						<th class="text-left">Narration</th>
						<th class="text-right">Debit</th>
						<th class="text-right">Credit</th>
						<th class="text-right">Balance</th>
					</tr>
				</thead>
				<tbody>
					{#each model.ledger.txs as t (t.id)}
						<tr>
							<td class="text-center print:hidden"
								><input type="checkbox" bind:checked={t.selected} /></td
							>
							<td class="text-center w-6">{dateFmt(new Date(t.date))}</td>
							<td class="text-center w-10 hidden sm:table-cell">{t.type}</td>
							<td class="text-left">{t.narration}</td>
							<td class="text-right">{moneyFmt(t.amount >= 0 ? t.amount : 0)}</td>
							<td class="text-right">{moneyFmt(t.amount < 0 ? Math.abs(t.amount) : 0)}</td>
							<td class="text-right">{moneyFmt(t.bal)}</td>
						</tr>
					{/each}
				</tbody>
				<tfoot class="border-b border-t border-gray-700">
					<tr>
						<th class="print:hidden"></th>
						<th></th>
						<th class="hidden sm:table-cell"></th>
						<th class="text-right">Total:</th>
						<th class="text-right">{moneyFmt(model.ledger.total_debit)}</th>
						<th class="text-right">{moneyFmt(Math.abs(model.ledger.total_credit))}</th>
						<th class="text-right"
							>{moneyFmt(model.ledger.cl_bal) === '' ? '0.00' : moneyFmt(model.ledger.cl_bal)}</th
						>
					</tr>
				</tfoot>
			</table>
		</div>
	</section>
{/await}
<section class="section print:hidden mb-4">
	<div class="wrapper">
		{#if newTxs.length > 0}
			<div class="overflow-auto">
				<table class="table w-full is-striped">
					<thead>
						<tr class="border-b border-gray-700">
							<th class="has-text-right max-w-5">#</th>
							<th class="w-5">Date</th>
							<th class="w-5">Type</th>
							<th class="text-left min-w-10">Narration</th>
							<th class="text-right min-w-32">Debit</th>
							<th class="text-right min-w-32">Credit</th>
							<th class="text-right w-5">Action</th>
						</tr>
					</thead>
					<tbody>
						{#each newTxs as t, i}
							<tr class="*:align-middle">
								<td class="text-right">{i + 1}</td>
								<td class="has-text-center"><input type="date" bind:value={t.date} /></td>
								<td>
									<select
										id="type"
										bind:value={t.type}
										class="pr-0"
										onchange={() => {
											t.debit = 0;
											t.credit = 0;
										}}
									>
										{#each types as v}
											<option>{v}</option>
										{/each}
									</select>
								</td>
								<td class="text-left"><input class="w-full" bind:value={t.narration} /></td>
								<td class="min-w-32"
									><input
										type="number"
										bind:value={t.debit}
										class="text-right w-full disabled:hidden"
										disabled={debitOrCreditTx(t.type)}
									/></td
								>
								<td class="min-w-32">
									<input
										type="number"
										bind:value={t.credit}
										class="text-right w-full disabled:hidden"
										disabled={!debitOrCreditTx(t.type)}
									/></td
								>
								<td>
									<span class="flex justify-center items-baseline">
										<button class="button mb-0" onclick={() => newTxs.splice(i, 1)}>-</button>
									</span>
								</td>
							</tr>
						{/each}
					</tbody>
					<tfoot class="border-b border-t border-gray-700">
						<tr class="*:p-1">
							<th>
								<button class="btn btn-primary mt-1 mb-0" onclick={() => addTx()}>+</button>
							</th>
							<th></th>
							<th></th>
							<th>
								<button class="btn btn-primary" onclick={() => submit()}>Submit</button>
							</th>
							<th class="text-right">{moneyFmt(debit)}</th>
							<th class="text-right">{moneyFmt(credit)}</th>
							<th class="text-right">{moneyFmt(total)}</th>
						</tr>
					</tfoot>
				</table>
			</div>
		{:else}
			<div class="flex flex-row-reverse pr-2">
				<button class="btn btn-primary" onclick={() => addTx()}>+</button>
			</div>
		{/if}
	</div>
</section>
