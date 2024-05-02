<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger, getLedgers, type Ledger } from '../store.svelte';
  import { moneyFmt } from '../utils';
  import Modal from '../lib/Modal.svelte';
  import { untrack } from 'svelte';

  type MyProps = { params: { fin_year: string } | undefined };
  let { params }: MyProps = $props();
  let isModalOpen = $state(false);
  let text = $state('');
  let filter: Ledger[] = $state([]);

  function ledgerDetails(code: string) {
    isModalOpen = true;
    getLedger(code, 8);
  }

  let ledgersStatus = $derived(appState.ledgers.status);
  let ledgers = $derived(appState.ledgers.data);
  let default_fin_year = $derived(appState.books[0].fin_year);

  $effect(() => {
    if (params === undefined) {
      untrack(() => getLedgers(default_fin_year));
    } else {
      untrack(() => getLedgers(parseInt(params!.fin_year, 10)));
    }
  });

  $effect(() => {
    if (text.trim().length >= 2) {
      let match = text.toLowerCase();
      filter = ledgers
        ? ledgers.filter((ledger: Ledger) => {
            return (
              ledger.name.toLowerCase().includes(match) ||
              ledger.code.toLowerCase().startsWith(match)
            );
          })
        : [];
    } else {
      filter = ledgers ? ledgers : [];
    }
  });
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
<section>
  <div class="wrapper">
    <div class="tabs">
      <ul class="flex-row-reverse" role="menu">
        {#each appState.books as book (book.id)}
          <li title={book.period} class:is-active={appState.fin_year === book.fin_year}>
            <a href="#/ledgers/{book.fin_year}">{book.fin_year}</a>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>
<section>
  <div class="wrapper flex-row flex gap-2 align-baseline text-center">
    <label for="filter" class="p-2">Filter:</label>
    <div class="flex-grow flex-1 flex">
      <input
        id="filter"
        type="search"
        class="flex-grow pl-2 border-gray-500 border"
        bind:value={text}
      />
    </div>
  </div>
</section>
<section>
  <div class="wrapper">
    {#if ledgersStatus === 'idle'}
      <div>Idle</div>
    {:else if ledgersStatus === 'loading'}
      <div>Loading...</div>
    {:else if ledgersStatus === 'timedout'}
      <div>Request Timed Out</div>
    {:else if ledgersStatus === 'error'}
      <div>Error occurred: {appState.ledgers.error}</div>
    {:else if ledgersStatus === 'loaded'}
      <div class="overflow-x-auto">
        <table class="table is-fullwidth is-striped is-hoverable is-narrow">
          <thead>
            <tr>
              <th class="has-text-right">#</th>
              <th class="has-text-left">Name</th>
              <th class="has-text-right">Opening</th>
              <th class="has-text-right">Debits</th>
              <th class="has-text-right">Credits</th>
              <th class="has-text-right">Closing</th>
            </tr>
          </thead>
          <tbody>
            {#each filter as ledger, i (ledger.id)}
              <tr>
                <td class="has-text-right">{i + 1}</td>
                <td>
                  <a href={`#/ledger/${encodeURIComponent(ledger.code)}/${appState.fin_year}`}
                    >{ledger.name}</a
                  >
                  <span class="tag is-normal is-link is-light">{ledger.code}</span>
                  <span class="tag is-info is-light">{ledger.region}</span>
                  <span class="tag is-warning is-light">{ledger.is_gov ? 'GOV' : 'PVT'}</span>
                  <button
                    class="hero-information-circle text-blue-400"
                    onclick={() => ledgerDetails(ledger.code)}>i</button
                  >
                </td>
                <td class="has-text-right">{moneyFmt(ledger.op_bal)}</td>
                <td class="has-text-right">{moneyFmt(ledger.total_debit)}</td>
                <td class="has-text-right">{moneyFmt(Math.abs(ledger.total_credit))}</td>
                <td class="has-text-right">{moneyFmt(ledger.cl_bal)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</section>
<Modal open={isModalOpen} onclose={() => (isModalOpen = false)}>
  <section>
    <div class="wrapper flex items-center justify-center">
      {#if appState.ledger.data}
        <table class="table">
          <tbody>
            {#each Object.entries(appState.ledger.data) as [key, value]}
              <tr>
                <th class="has-text-right">{key}:</th>
                <td>{value}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      {/if}
    </div>
  </section>
</Modal>
