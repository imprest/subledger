<script lang="ts">
  import { onMount } from 'svelte';
  import { state, getLedger, getLedgers, type Ledger } from '../store';
  import { useSnapshot } from 'sveltio';
  import { debounce, moneyFmt } from '../utils';
  import Modal from '../lib/Modal.svelte';
  import { Info, Eye } from 'lucide-svelte';

  export let book_id: string = '';
  let isModalOpen = false;
  let text = '';
  let filter: Ledger[] = [];

  onMount((book_id: string) => {
    getLedgers(book_id);
  });

  const snap = useSnapshot(state);

  function ledgerDetails(id: string) {
    isModalOpen = true;
    getLedger(id);
  }

  function filterLedgers() {
    if (text.trim().length >= 2) {
      let match = text.toLowerCase();
      filter = $snap.ledgers.data.filter((ledger: Ledger) => {
        return (
          ledger.name.toLowerCase().includes(match) || ledger.code.toLowerCase().startsWith(match)
        );
      });
    } else {
      filter = $snap.ledgers.data;
    }
  }

  $: if ($snap.ledgers.status == 'loaded') {
    filter = $snap.ledgers.data;
  }
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
        {#each $snap.books as book (book.id)}
          <li title={book.period}>
            <a href={`\\app\\${book.id}`}>{book.fin_year}</a>
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
        on:keyup={debounce(filterLedgers, 120)}
      />
    </div>
  </div>
</section>
<section>
  <div class="wrapper">
    {#if $snap.ledgers.status === 'idle'}
      <div>Idle</div>
    {:else if $snap.ledgers.status === 'loading'}
      <div>Loading...</div>
    {:else if $snap.ledgers.status === 'timedout'}
      <div>Request Timed Out</div>
    {:else if $snap.ledgers.status === 'error'}
      <div>Error occurred: {$snap.ledgers.error}</div>
    {:else if $snap.ledgers.status === 'loaded'}
      <table class="table w-full is-bordered is-striped">
        <thead>
          <tr>
            <th>#</th>
            <th class="text-left">Name</th>
            <th class="text-right">Balance</th>
          </tr>
        </thead>
        <tbody>
          {#each filter as ledger, i (ledger.id)}
            <tr>
              <td class="text-center">{i + 1}</td>
              <td>
                <button on:click={() => ledgerDetails(ledger.id)}
                  ><Info class="inline-block h-4 text-blue-600" /></button
                >
                {ledger.name}
                <ul class="tags inline-block pl-2">
                  <li class="tag inline bg-orange-200">{ledger.code}</li>
                  <li class="tag inline bg-blue-200">{ledger.region}</li>
                </ul>
                <a class="float-right" href="/app/ledger/{ledger.id}"
                  ><Eye class="inline-block h-4 text-blue-600" /></a
                >
              </td>
              <td class="text-right">{moneyFmt(ledger.op_bal)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>
</section>
<Modal open={isModalOpen} on:close={() => (isModalOpen = false)}>
  <section>
    <div class="wrapper flex items-center justify-center">
      {#if $snap.ledger}
        <table class="table">
          {#each Object.entries($snap.ledger) as [key, value]}
            <tr>
              <th class="text-right">{key}:</th>
              <td>{value}</td>
            </tr>
          {/each}
        </table>
      {/if}
    </div>
  </section>
</Modal>
