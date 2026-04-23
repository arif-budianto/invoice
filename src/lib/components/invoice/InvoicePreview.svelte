<script lang="ts">
	import type { InvoiceFormData, InvoiceItem } from '$lib/types/invoice';

	type Props = {
		form: InvoiceFormData;
		items: InvoiceItem[];
		subtotal: number;
		taxRate: number;
		taxAmount: number;
		total: number;
		formatCurrency: (value: number) => string;
		formatDate: (value: string) => string;
	};

	let { form, items, subtotal, taxRate, taxAmount, total, formatCurrency, formatDate }: Props =
		$props();

	let isDownloading = $state(false);
	let downloadError = $state<string | null>(null);
	let downloadStatus = $state<string | null>(null);

	const handleDownloadPdf = async () => {
		if (typeof window === 'undefined' || isDownloading) return;

		downloadError = null;
		downloadStatus = 'Membuka dialog print...';
		isDownloading = true;

		try {
			window.print();
			downloadStatus = 'Pilih Save as PDF dari dialog print browser.';
		} catch (error) {
			console.error('Gagal membuka dialog print invoice:', error);
			downloadError =
				error instanceof Error && error.message
					? `Gagal membuka dialog print: ${error.message}`
					: 'Gagal membuka dialog print. Silakan coba lagi.';
			downloadStatus = null;
		} finally {
			isDownloading = false;
		}
	};
</script>

<section class="invoice-preview-section space-y-4 lg:sticky lg:top-6">
	<div class="invoice-preview-controls space-y-2">
		<div class="flex items-center justify-end">
			<button
				type="button"
				onclick={handleDownloadPdf}
				disabled={isDownloading}
				class="inline-flex w-full items-center justify-center rounded-2xl border border-white/12 bg-white/8 px-4 py-3 text-sm font-semibold text-white transition hover:border-cyan-300/30 hover:bg-white/12 disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto"
			>
				{isDownloading ? 'Membuka print...' : 'Download PDF'}
			</button>
		</div>

		{#if downloadStatus}
			<p class="text-right text-sm text-slate-300">{downloadStatus}</p>
		{/if}

		{#if downloadError}
			<p class="text-right text-sm text-red-300">{downloadError}</p>
		{/if}
	</div>

	<section
		class="invoice-preview-document rounded-[28px] border border-cyan-400/20 bg-[#f8fafc] p-5 text-slate-900 shadow-[0_24px_90px_rgba(8,15,32,0.35)] sm:p-7 lg:p-8"
	>
		<div class="space-y-8">
			<div
				class="flex flex-col gap-6 border-b border-slate-200 pb-6 sm:flex-row sm:items-start sm:justify-between"
			>
				<div class="space-y-3">
					<div
						class="invoice-preview-badge inline-flex rounded-full border border-cyan-200 bg-cyan-50 px-3 py-1 text-[11px] font-semibold tracking-[0.24em] text-cyan-700 uppercase"
					>
						Invoice preview
					</div>
					<div>
						<h2 class="text-3xl font-semibold tracking-tight text-slate-950">
							{form.fromName || 'Nama bisnis'}
						</h2>
						<p class="mt-2 max-w-sm text-sm leading-6 text-slate-500">
							{form.fromAddress || 'Alamat bisnis'} · {form.fromPhone || 'Telepon'} · {form.fromEmail ||
								'Email'}
						</p>
					</div>
				</div>
				<div class="space-y-2 text-sm text-slate-500 sm:text-right">
					<p class="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">Nomor</p>
					<p class="text-lg font-semibold text-slate-900">{form.invoiceNumber}</p>
					<div class="grid gap-1">
						<p>Terbit: {formatDate(form.issueDate)}</p>
						<p>Jatuh tempo: {formatDate(form.dueDate)}</p>
					</div>
				</div>
			</div>

			<div class="grid gap-6 sm:grid-cols-2">
				<div class="space-y-2">
					<p class="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">
						Ditagihkan ke
					</p>
					<div class="space-y-1 text-sm text-slate-600">
						<p class="text-base font-semibold text-slate-950">{form.clientName || 'Nama klien'}</p>
						<p>{form.clientEmail || 'Email klien'}</p>
						<p>{form.clientPhone || 'Telepon klien'}</p>
						<p>{form.clientAddress || 'Alamat klien'}</p>
					</div>
				</div>
				<div class="space-y-2">
					<p class="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">Ringkasan</p>
					<div class="rounded-2xl border border-slate-200 bg-white px-4 py-4">
						<div class="flex items-center justify-between py-2 text-sm text-slate-600">
							<span>Subtotal</span>
							<span class="font-medium text-slate-900">{formatCurrency(subtotal)}</span>
						</div>
						<div class="flex items-center justify-between py-2 text-sm text-slate-600">
							<span>Pajak ({taxRate}%)</span>
							<span class="font-medium text-slate-900">{formatCurrency(taxAmount)}</span>
						</div>
						<div
							class="mt-2 flex items-center justify-between border-t border-slate-200 pt-4 text-base font-semibold text-slate-950"
						>
							<span>Total</span>
							<span>{formatCurrency(total)}</span>
						</div>
					</div>
				</div>
			</div>

			<div
				class="space-y-3 sm:space-y-0 sm:overflow-hidden sm:rounded-3xl sm:border sm:border-slate-200"
			>
				<div
					class="hidden grid-cols-[minmax(0,1.7fr)_0.7fr_1fr_1fr] gap-3 bg-slate-50 px-4 py-3 text-xs font-semibold tracking-[0.18em] text-slate-500 uppercase sm:grid"
				>
					<span>Deskripsi</span>
					<span>Qty</span>
					<span>Harga</span>
					<span class="text-right">Jumlah</span>
				</div>
				<div class="space-y-3 sm:space-y-0 sm:divide-y sm:divide-slate-200 sm:bg-white">
					{#each items as item (item.id)}
						<div class="rounded-2xl border border-slate-200 bg-white p-4 sm:hidden">
							<div class="space-y-3 text-sm text-slate-600">
								<div class="space-y-1">
									<p class="text-[11px] font-semibold tracking-[0.18em] text-slate-400 uppercase">
										Deskripsi
									</p>
									<p class="font-medium text-slate-900">{item.description || 'Item pekerjaan'}</p>
								</div>
								<div class="grid grid-cols-2 gap-3">
									<div class="space-y-1">
										<p class="text-[11px] font-semibold tracking-[0.18em] text-slate-400 uppercase">
											Qty
										</p>
										<p class="font-medium text-slate-900">{item.quantity}</p>
									</div>
									<div class="space-y-1">
										<p class="text-[11px] font-semibold tracking-[0.18em] text-slate-400 uppercase">
											Harga
										</p>
										<p class="font-medium text-slate-900">{formatCurrency(item.unitPrice)}</p>
									</div>
								</div>
								<div class="border-t border-slate-200 pt-3">
									<div class="flex items-center justify-between gap-3">
										<p class="text-[11px] font-semibold tracking-[0.18em] text-slate-400 uppercase">
											Jumlah
										</p>
										<p class="font-semibold text-slate-900">
											{formatCurrency(item.quantity * item.unitPrice)}
										</p>
									</div>
								</div>
							</div>
						</div>
						<div
							class="hidden grid-cols-[minmax(0,1.7fr)_0.7fr_1fr_1fr] gap-3 px-4 py-4 text-sm text-slate-600 sm:grid"
						>
							<div>
								<p class="font-medium text-slate-900">{item.description || 'Item pekerjaan'}</p>
							</div>
							<p>{item.quantity}</p>
							<p>{formatCurrency(item.unitPrice)}</p>
							<p class="text-right font-medium text-slate-900">
								{formatCurrency(item.quantity * item.unitPrice)}
							</p>
						</div>
					{/each}
				</div>
			</div>

			<div class="grid gap-6 border-t border-slate-200 pt-6 sm:grid-cols-[1.2fr_0.8fr]">
				<div class="space-y-2">
					<p class="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">Catatan</p>
					<p class="text-sm leading-6 text-slate-600">{form.notes}</p>
				</div>
				<div class="space-y-2 rounded-2xl bg-slate-950 px-5 py-5 text-sm text-slate-300">
					<p class="text-xs font-semibold tracking-[0.2em] text-slate-500 uppercase">Pembayaran</p>
					<p class="text-xl font-semibold text-white">{formatCurrency(total)}</p>
					<p>Mohon lakukan pembayaran sebelum {formatDate(form.dueDate)}.</p>
				</div>
			</div>
		</div>
	</section>
</section>
