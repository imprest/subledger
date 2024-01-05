<svelte:options runes={true} />

<script lang="ts">
  import { appState, getLedger, getLedgers, type Ledger } from '../store.svelte';
  import { moneyFmt } from '../utils';
  import Modal from '../lib/Modal.svelte';
  import { Link } from 'svelte-pilot';

  let { book_id = '' } = $props();
  let isModalOpen = $state(false);
  let text = $state('');
  let filter: Ledger[] = $state([]);

  function ledgerDetails(id: string) {
    isModalOpen = true;
    getLedger(id);
  }

  let ledgersStatus = $derived(appState.ledgers.status);
  let ledgers = $derived(appState.ledgers.data);

  $effect(() => {
    if (book_id === '') {
      book_id = appState.book_id;
    }

    if (ledgersStatus === 'idle') {
      getLedgers(book_id);
    }

    if (ledgersStatus === 'loaded' && book_id !== appState.book_id) {
      getLedgers(book_id);
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
          <li title={book.period} class:is-active={appState.book_id === book.id}>
            <Link to={`/ledgers?fin_year=${book.id}`}>{book.fin_year}</Link>
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
        <table class="table w-full is-bordered is-striped">
          <thead>
            <tr>
              <th class="text-right">#</th>
              <th class="text-left">Name</th>
              <th class="text-right">Opening</th>
              <th class="text-right">Closing</th>
            </tr>
          </thead>
          <tbody>
            {#each filter as ledger, i (ledger.id)}
              <tr>
                <td class="text-right">{i + 1}</td>
                <td>
                  <Link to={`/ledgers/${encodeURIComponent(ledger.id)}`}>{ledger.name}</Link>
                  <ul class="tags inline-block pl-2">
                    <li class="tag inline bg-orange-200">{ledger.code}</li>
                    <li class="tag inline bg-blue-200">{ledger.region}</li>
                    <li class="tag inline bg-purple-300">{ledger.is_gov ? 'GOV' : 'PVT'}</li>
                  </ul>
                  <button on:click={() => ledgerDetails(ledger.id)}
                    ><span class="inline-block h-4 text-blue-600">i</span></button
                  >
                </td>
                <td class="text-right">{moneyFmt(ledger.op_bal)}</td>
                <td class="text-right">{moneyFmt(ledger.cl_bal)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</section>
<Modal open={isModalOpen} on:close={() => (isModalOpen = false)}>
  <section>
    <div class="wrapper flex items-center justify-center">
      {#if appState.ledger.data}
        <table class="table">
          <tbody>
            {#each Object.entries(appState.ledger.data) as [key, value]}
              <tr>
                <th class="text-right">{key}:</th>
                <td>{value}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      {/if}
    </div>
  </section>
</Modal>
