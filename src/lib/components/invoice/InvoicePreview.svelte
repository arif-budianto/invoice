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
</script>

<section
	class="rounded-[28px] border border-cyan-400/20 bg-[#f8fafc] p-5 text-slate-900 shadow-[0_24px_90px_rgba(8,15,32,0.35)] sm:p-7 lg:sticky lg:top-6 lg:p-8"
>
	<div class="space-y-8">
		<div
			class="flex flex-col gap-6 border-b border-slate-200 pb-6 sm:flex-row sm:items-start sm:justify-between"
		>
			<div class="space-y-3">
				<div
					class="inline-flex rounded-full border border-cyan-200 bg-cyan-50 px-3 py-1 text-[11px] font-semibold tracking-[0.24em] text-cyan-700 uppercase"
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
				<p class="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">Ditagihkan ke</p>
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

		<div class="overflow-hidden rounded-3xl border border-slate-200">
			<div
				class="grid grid-cols-[minmax(0,1.7fr)_0.7fr_1fr_1fr] gap-3 bg-slate-50 px-4 py-3 text-xs font-semibold tracking-[0.18em] text-slate-500 uppercase"
			>
				<span>Deskripsi</span>
				<span>Qty</span>
				<span>Harga</span>
				<span class="text-right">Jumlah</span>
			</div>
			<div class="divide-y divide-slate-200 bg-white">
				{#each items as item (item.id)}
					<div
						class="grid grid-cols-[minmax(0,1.7fr)_0.7fr_1fr_1fr] gap-3 px-4 py-4 text-sm text-slate-600"
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
