<script lang="ts">
	import InvoiceForm from '$lib/components/invoice/InvoiceForm.svelte';
	import InvoicePreview from '$lib/components/invoice/InvoicePreview.svelte';
	import type { InvoiceFormData, InvoiceItem } from '$lib/types/invoice';

	const createInvoiceItem = (
		id: number,
		description = '',
		quantity = 1,
		unitPrice = 0
	): InvoiceItem => ({
		id,
		description,
		quantity,
		unitPrice
	});

	const DAY_IN_MS = 24 * 60 * 60 * 1000;
	const now = Date.now();
	const issueDateValue = new Date(now);
	const dueDateValue = new Date(now + DAY_IN_MS * 14);

	const formatDateInput = (value: Date) => value.toISOString().slice(0, 10);

	let nextItemId = 3;
	let taxRate = $state(11);
	let form = $state<InvoiceFormData>({
		invoiceNumber: 'INV-2026-001',
		issueDate: formatDateInput(issueDateValue),
		dueDate: formatDateInput(dueDateValue),
		currency: 'IDR',
		notes:
			'Terima kasih atas kepercayaan Anda. Pembayaran dapat dilakukan sesuai termin yang telah disepakati.',
		fromName: 'Studio Arunika',
		fromEmail: 'halo@arunika.id',
		fromPhone: '0812 0000 0000',
		fromAddress: 'Jakarta, Indonesia',
		clientName: 'PT Sinar Utama',
		clientEmail: 'finance@sinarutama.co.id',
		clientPhone: '021 5555 9999',
		clientAddress: 'Bandung, Indonesia'
	});

	let items = $state<InvoiceItem[]>([
		createInvoiceItem(1, 'Design system & UI refinement', 1, 4500000),
		createInvoiceItem(2, 'Frontend development', 1, 8500000)
	]);

	const subtotal = $derived(items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0));
	const taxAmount = $derived(Math.round(subtotal * (taxRate / 100)));
	const total = $derived(subtotal + taxAmount);

	const formatCurrency = (value: number) =>
		new Intl.NumberFormat('id-ID', {
			style: 'currency',
			currency: form.currency,
			maximumFractionDigits: form.currency === 'IDR' ? 0 : 2
		}).format(value);

	const formatDate = (value: string) =>
		new Intl.DateTimeFormat('id-ID', {
			day: '2-digit',
			month: 'long',
			year: 'numeric'
		}).format(new Date(value));

	const addItem = () => {
		items = [...items, createInvoiceItem(nextItemId++)];
	};

	const removeItem = (id: number) => {
		if (items.length === 1) return;
		items = items.filter((item) => item.id !== id);
	};
</script>

<svelte:head>
	<title>Invoice Builder</title>
	<meta
		name="description"
		content="Web pembuatan invoice dengan tampilan modern, profesional, dan preview langsung."
	/>
</svelte:head>

<div
	class="min-h-screen bg-[radial-gradient(circle_at_top,rgba(34,211,238,0.14),transparent_28%),linear-gradient(180deg,#020617_0%,#020817_42%,#020617_100%)]"
>
	<div
		class="mx-auto flex min-h-screen max-w-400 flex-col gap-6 px-4 py-4 sm:px-6 sm:py-6 xl:px-8 xl:py-8"
	>
		<div class="grid gap-6 lg:grid-cols-[minmax(0,1.02fr)_minmax(420px,0.98fr)] xl:gap-8">
			<div class="space-y-6">
				<InvoiceForm {form} {items} onAddItem={addItem} onRemoveItem={removeItem} />

				<section
					class="grid gap-4 rounded-[28px] border border-white/10 bg-white/5 p-5 sm:grid-cols-[1fr_auto] sm:items-end sm:p-7"
				>
					<div class="space-y-2">
						<p class="text-xs font-medium tracking-[0.24em] text-slate-500 uppercase">
							Pengaturan total
						</p>
						<h2 class="text-xl font-semibold text-white">Ringkasan nilai tagihan</h2>
						<p class="text-sm leading-6 text-slate-400">
							Atur pajak seperlunya, total invoice akan diperbarui otomatis.
						</p>
					</div>
					<label class="space-y-2 sm:min-w-40">
						<span class="text-sm font-medium text-slate-200">Pajak (%)</span>
						<input bind:value={taxRate} class="field" min="0" max="100" type="number" />
					</label>
				</section>
			</div>

			<InvoicePreview
				{form}
				{items}
				{subtotal}
				{taxRate}
				{taxAmount}
				{total}
				{formatCurrency}
				{formatDate}
			/>
		</div>
	</div>
</div>
