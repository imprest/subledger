<script lang="ts">
	import Home from './routes/Home.svelte';
	import Activity from './routes/Activity.svelte';
	import Ledger from './routes/Ledger.svelte';
	import type { Route } from '@mateothegreat/svelte5-router';
	import { route, Router } from '@mateothegreat/svelte5-router';
	import { channel } from './service.svelte';

	let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute('content');

	const routes: Route[] = [
		{ path: '/activity', component: Activity },
		{ path: '/ledgers/(?<code>.*)/(?<fin_year>.*)', component: Ledger },
		{ path: '/ledgers/(?<code>.*)', component: Ledger },
		{ path: '(?<route>.*)', component: Home }
	];

	const appInitHook = async (route: Route): Promise<Route> => {
		await channel.getBooks();
		return route;
	};
</script>

<header class="header print:hidden">
	<nav class="nav">
		<ul>
			<li><strong>SubLedger</strong></li>
			<li><a use:route href="/app">Home</a></li>
			<li><a use:route href="/app/activity">Activity</a></li>
		</ul>
		<ul>
			<li>
				<a data-csrf={csrfToken} data-method="delete" data-to="/users/log_out" href="/users/log_out"
					>Logout</a
				>
			</li>
		</ul>
	</nav>
</header>
<main class="pt-3">
	<Router basePath="/app" {routes} pre={appInitHook} />
</main>
