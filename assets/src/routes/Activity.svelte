<script lang="ts">
	type MyProps = { params: string[] };
	let { params }: MyProps = $props();
</script>

<section class="section mx-auto">
	<pre>{JSON.stringify(params, null, 2)}</pre>
	<div class="flex flex-col sm:flex-row gap-2 items-baseline">
		<button class="btn">Test</button>
	</div>
</section>
