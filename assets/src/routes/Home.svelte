<script lang="ts">
	import { model } from '../model.svelte';
	import { channel } from '../service.svelte';
	import { moneyFmt } from '../utils';
	import type { Ledger } from '../types';
	import { goto } from '@mateothegreat/svelte5-router';

	type MyProps = { params: { route: string } };
	let { params }: MyProps = $props();
	let text = $state('');

	let year = $state(model.books[0].fin_year);
	let selectYear;

	let filter = $derived.by(() => {
		let match = text.toLowerCase();
		return model.ledgers.filter((ledger: Ledger) => {
			return (
				ledger.name.toLowerCase().includes(match) || ledger.code.toLowerCase().startsWith(match)
			);
		});
	});

	function yearChanged() {
		history.replaceState(null, '', `/app/${year}`);
		// history.pushState(null, '', `/app/${year}`);
		// goto(`/app/${year}`);
	}

	// On mount determine which year to use
	$effect.pre(() => {
		if (params.route === '/app' || params.route === '/app/') return channel.getLedgers(year);
		let parsedParams = params.route.replaceAll('/', ' ').trim().split(' ');
		let y = Number.parseInt(parsedParams[parsedParams.length - 1]);
		const fin_years = model.books.map((b) => b.fin_year);
		fin_years.includes(y) ? (year = y) : (year = model.books[0].fin_year);
	});

	$effect(() => selectYear.focus());

	// function handleSelect(e: { detail: Ledger }) {
	//   selected = e.detail;
	//   text = selected.name;
	//   console.log(e.detail);
	// }
</script>

<!-- <section> -->
<!--   <div class="wrapper"> -->
<!--     <Autocomplete -->
<!--       id="customer" -->
<!--       labelName="Quick Filter: " -->
<!--       bind:value={text} -->
<!--       on:select={handleSelect} -->
<!--       data={$snap.ledgers.data} -->
<!--       let:item -->
<!--     > -->
<!--       <div class="flex flex-start px-4 py-2"> -->
<!--         <div class="flex-auto text-sm sm:overflow-x-auto"> -->
<!--           {item.name} -->
<!--           <br /> -->
<!--           <small class="text-xs pt"> -->
<!--             <b>{item.code}</b> -->
<!--             <b>{item.town_city}</b> -->
<!--             <b>{item.region}</b> -->
<!--             <b>{item.is_gov ? 'GOV' : 'PVT'}</b> -->
<!--           </small> -->
<!--         </div> -->
<!--       </div> -->
<!--     </Autocomplete> -->
<!--   </div> -->
<!-- </section> -->
<!-- <section class="section"> -->
<!-- 	<div class="tabs"> -->
<!-- 		<ul role="menu" class="is-flex-direction-row-reverse"> -->
<!-- 			{#each model.books as book (book.id)} -->
<!-- 				<li title={book.period} class:is-active={2021 === book.fin_year}> -->
<!-- 					<a href="#/ledgers/{book.fin_year}">{book.fin_year}</a> -->
<!-- 				</li> -->
<!-- 			{/each} -->
<!-- 		</ul> -->
<!-- 	</div> -->
<!-- </section> -->
<section class="section">
	<div class="flex flex-center gap-2">
		<label for="filter" class="pl-2"> Filter: </label>
		<input
			id="filter"
			class="input w-full"
			type="search"
			bind:value={text}
			placeholder="Find a customer ledger"
		/>
		<div class="select-combo">
			<label for="book">Year</label>
			<select id="book" bind:this={selectYear} bind:value={year} onchange={yearChanged}>
				{#each model.books as book}
					<option>{book.fin_year}</option>
				{/each}
			</select>
		</div>
	</div>
</section>
<section class="section">
	{#await channel.getLedgers(+year)}
		<div><p>Loading...</p></div>
	{:then}
		<div class="overflow-x-auto">
			<table class="table w-full is-striped is-hoverable">
				<thead>
					<tr>
						<th class="text-right">#</th>
						<th class="text-left">Name</th>
						<th class="text-right hidden sm:table-cell">Opening</th>
						<th class="text-right hidden md:table-cell">Debits</th>
						<th class="text-right hidden md:table-cell">Credits</th>
						<th class="text-right">Closing</th>
					</tr>
				</thead>
				<tbody>
					{#each filter as ledger, i (ledger.id)}
						<tr>
							<td class="text-right">{i + 1}</td>
							<td
								><a
									class="cursor-pointer text-black"
									href={`/app/ledgers/${encodeURIComponent(ledger.code)}/${model.fin_year}`}
									>{ledger.name}</a
								>
								<span
									class="tags inline-flex *:mb-0.5 *:text-[0.7em] *:py-0 align-middle font-semibold"
								>
									<span class="bg-primary/70 text-white">{ledger.code}</span>
									<span>{ledger.region}</span>
									<span class="bg-yellow-400">{ledger.is_gov ? 'GOV' : 'PVT'}</span>
									<span class="cursor-pointer hero-information-circle-mini h-5 bg-gray-600"></span>
								</span>
							</td>
							<td class="text-right hidden sm:table-cell">{moneyFmt(ledger.op_bal)}</td>
							<td class="text-right hidden md:table-cell">{moneyFmt(ledger.total_debit)}</td>
							<td class="text-right hidden md:table-cell"
								>{moneyFmt(Math.abs(ledger.total_credit))}</td
							>
							<td class="text-right">{moneyFmt(ledger.cl_bal)}</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/await}
</section>
