<script lang="ts">
	import { fade } from 'svelte/transition';
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
	const clampNumber = (value: number, min: number, max: number) => {
		if (!Number.isFinite(value)) return min;
		return Math.min(Math.max(value, min), max);
	};
	const normalizeQuantity = (value: number) =>
		Math.max(1, Math.floor(clampNumber(value, 1, 999999)));
	const normalizeAmount = (value: number) =>
		Math.max(0, clampNumber(value, 0, Number.MAX_SAFE_INTEGER));
	const normalizeTaxRate = (value: number) => clampNumber(value, 0, 100);

	let nextItemId = 3;
	let taxRate = $state(11);
	let showPreview = $state(false);
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
		clientAddress: 'Bandung, Indonesia',
		bankName: 'BCA',
		bankAccount: '1234 5678 910',
		bankAccountName: 'PT Studio Arunika',
		discount: 0
	});

	let items = $state<InvoiceItem[]>([
		createInvoiceItem(1, 'Design system & UI refinement', 1, 4500000),
		createInvoiceItem(2, 'Frontend development', 1, 8500000)
	]);

	const validatedTaxRate = $derived(normalizeTaxRate(taxRate));
	const subtotal = $derived(
		items.reduce(
			(sum, item) => sum + normalizeQuantity(item.quantity) * normalizeAmount(item.unitPrice),
			0
		)
	);
	const validatedDiscountRate = $derived(
		Number.isFinite(form.discount) && form.discount >= 0 && form.discount <= 100
			? form.discount
			: 0
	);

	const discountAmount = $derived(Math.round(subtotal * (validatedDiscountRate / 100)));
	const subtotalAfterDiscount = $derived(Math.max(0, subtotal - discountAmount));
	const taxAmount = $derived(Math.round(subtotalAfterDiscount * (validatedTaxRate / 100)));
	const total = $derived(subtotalAfterDiscount + taxAmount);

	const handleTaxBlur = () => {
		taxRate = validatedTaxRate;
	};



	const formatCurrency = (value: number) =>
		new Intl.NumberFormat('id-ID', {
			style: 'currency',
			currency: form.currency,
			maximumFractionDigits: form.currency === 'IDR' ? 0 : 2
		}).format(value);

	const formatDate = (value: string) => {
		const date = new Date(value);

		if (!value || Number.isNaN(date.getTime())) {
			return 'Tanggal belum diisi';
		}

		return new Intl.DateTimeFormat('id-ID', {
			day: '2-digit',
			month: 'long',
			year: 'numeric'
		}).format(date);
	};

	const addItem = () => {
		items = [...items, createInvoiceItem(nextItemId++)];
	};

	const removeItem = (id: number) => {
		if (items.length === 1) return;
		items = items.filter((item) => item.id !== id);
	};
</script>

<svelte:head>
	<title
		>{form.invoiceNumber
			? `${form.invoiceNumber} - ${form.clientName || 'Invoice'}`
			: 'Invoice Builder'}</title
	>
	<meta
		name="description"
		content="Web pembuatan invoice dengan tampilan modern, profesional, dan preview langsung."
	/>
	<style>
		@media print {
			@page {
				size: A4 portrait;
				margin: 15mm;
			}
			body {
				-webkit-print-color-adjust: exact !important;
				print-color-adjust: exact !important;
			}
		}
	</style>
</svelte:head>

<div
	class="min-h-screen bg-[radial-gradient(circle_at_top,rgba(34,211,238,0.14),transparent_28%),linear-gradient(180deg,#020617_0%,#020817_42%,#020617_100%)] print:min-h-0 print:bg-none"
>
	<div
		class="mx-auto flex min-h-screen max-w-[1600px] flex-col gap-8 px-4 py-4 sm:px-6 sm:py-6 xl:flex-row xl:px-8 xl:py-12 print:m-0 print:block print:min-h-0 print:w-full print:max-w-none print:p-0"
	>
		<div class="w-full xl:w-1/2 {showPreview ? 'hidden xl:block' : 'block'} print:hidden">
			<div in:fade={{ duration: 200 }} class="space-y-6">
				<InvoiceForm {form} {items} onAddItem={addItem} onRemoveItem={removeItem} />

				<section
					class="flex flex-col gap-6 rounded-[28px] border border-white/10 bg-white/5 p-5 backdrop-blur sm:flex-row sm:items-end sm:justify-between sm:p-7"
				>
					<div class="space-y-2">
						<p class="text-xs font-medium tracking-[0.24em] text-slate-500 uppercase">
							Pengaturan total
						</p>
						<h2 class="text-xl font-semibold text-white">Ringkasan nilai tagihan</h2>
						<p class="max-w-sm text-sm leading-6 text-slate-400">
							Atur diskon dan pajak seperlunya, total invoice akan diperbarui otomatis.
						</p>
					</div>
					<div class="flex w-full shrink-0 gap-4 sm:w-auto">
						<label class="w-24 shrink-0 space-y-2">
							<span class="text-sm font-medium text-slate-200">Diskon (%)</span>
							<input
								bind:value={form.discount}
								class="field w-full"
								min="0"
								max="100"
								type="number"
							/>
						</label>
						<label class="w-24 shrink-0 space-y-2">
							<span class="text-sm font-medium text-slate-200">Pajak (%)</span>
							<input
								bind:value={taxRate}
								class="field w-full"
								min="0"
								max="100"
								type="number"
								onblur={handleTaxBlur}
							/>
						</label>
					</div>
				</section>

				<button
					class="mt-4 w-full cursor-pointer rounded-[24px] border border-cyan-400/30 bg-cyan-400/10 p-4 text-center text-lg font-bold text-cyan-50 shadow-[0_0_30px_rgba(34,211,238,0.15)] transition-all hover:scale-[1.01] hover:bg-cyan-400/20 xl:hidden"
					onclick={() => (showPreview = true)}
				>
					Lihat Hasil Preview
				</button>
			</div>
		</div>

		<div
			class="w-full xl:w-1/2 {showPreview
				? 'block'
				: 'hidden xl:block'} print:m-0 print:block print:w-full print:max-w-none print:p-0"
		>
			<div
				in:fade={{ duration: 200 }}
				class="space-y-6 xl:sticky xl:top-8 print:static print:block"
			>
				<button
					class="group flex cursor-pointer items-center gap-2 text-sm font-semibold text-cyan-400 transition hover:text-cyan-300 xl:hidden"
					onclick={() => (showPreview = false)}
				>
					<span class="transition-transform group-hover:-translate-x-1">&larr;</span>
					Kembali Edit Formulir
				</button>

				<InvoicePreview
					{form}
					{items}
					{subtotal}
					{discountAmount}
					taxRate={validatedTaxRate}
					{taxAmount}
					{total}
					{formatCurrency}
					{formatDate}
				/>
			</div>
		</div>
	</div>
</div>
