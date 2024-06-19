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

  function ledgerDetails(code: string, fin_year: number) {
    isModalOpen = true;
    getLedger(code, fin_year);
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
<section class="section pt-0 pb-4 px-0">
  <div class="container">
    <div class="tabs pt-2">
      <ul role="menu" class="is-flex-direction-row-reverse">
        {#each appState.books as book (book.id)}
          <li title={book.period} class:is-active={appState.fin_year === book.fin_year}>
            <a href="#/ledgers/{book.fin_year}">{book.fin_year}</a>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>
<section class="section pt-0 pb-4 px-2">
  <div class="container">
    <div class="field has-addons">
      <div class="control">
        <button class="button is-static"> Filter </button>
      </div>
      <div class="control is-expanded">
        <input
          id="filter"
          class="input"
          type="search"
          bind:value={text}
          placeholder="Find a customer ledger"
        />
      </div>
    </div>
  </div>
</section>
<section class="section pt-0 px-0">
  <div class="container">
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
                    class="button button-primary is-small"
                    onclick={() => ledgerDetails(ledger.code, appState.fin_year)}>ð</button
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
<Modal open={isModalOpen}>
  <section class="section">
    <div class="container">
      {#if appState.ledger.data}
        <table class="table is-fullwidth is-striped is-hoverable is-narrow">
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
