<script lang="ts">
	import type { InvoiceFormData, InvoiceItem } from '$lib/types/invoice';

	type Props = {
		form: InvoiceFormData;
		items: InvoiceItem[];
		onAddItem: () => void;
		onRemoveItem: (id: number) => void;
	};

	let { form, items, onAddItem, onRemoveItem }: Props = $props();

	const priceFormatter = new Intl.NumberFormat('id-ID');
	let priceDrafts = $state<Record<number, string>>({});
	let focusedPriceInputs = $state<Record<number, boolean>>({});

	function formatPrice(value: number) {
		if (!Number.isFinite(value) || value <= 0) {
			return '';
		}

		return priceFormatter.format(value);
	}

	function getPriceInputValue(item: InvoiceItem) {
		if (focusedPriceInputs[item.id]) {
			return priceDrafts[item.id] ?? (item.unitPrice > 0 ? String(item.unitPrice) : '');
		}

		return priceDrafts[item.id] ?? formatPrice(item.unitPrice);
	}

	function handlePriceFocus(item: InvoiceItem) {
		focusedPriceInputs[item.id] = true;
		priceDrafts[item.id] = item.unitPrice > 0 ? String(item.unitPrice) : '';
	}

	function handlePriceInput(item: InvoiceItem, event: Event) {
		const input = event.currentTarget as HTMLInputElement;
		const rawValue = input.value.replace(/\D/g, '');

		priceDrafts[item.id] = rawValue;
		item.unitPrice = rawValue ? Number(rawValue) : 0;
	}

	function handlePriceBlur(item: InvoiceItem) {
		focusedPriceInputs[item.id] = false;
		priceDrafts[item.id] = formatPrice(item.unitPrice);
	}
</script>

<section
	class="space-y-8 rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-[0_24px_80px_rgba(15,23,42,0.28)] backdrop-blur sm:p-7 lg:p-8"
>
	<div class="space-y-2">
		<p class="text-xs font-medium tracking-[0.28em] text-cyan-300/80 uppercase">Invoice builder</p>
		<div class="space-y-2">
			<h1 class="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
				Buat invoice yang rapi dalam satu alur kerja.
			</h1>
			<p class="max-w-2xl text-sm leading-6 text-slate-400 sm:text-[15px]">
				Isi data utama di kiri, lalu cek hasil invoice secara langsung di panel preview.
			</p>
		</div>
	</div>

	<div class="grid gap-4 sm:grid-cols-2">
		<label class="space-y-2">
			<span class="text-sm font-medium text-slate-200">Nomor invoice</span>
			<input bind:value={form.invoiceNumber} class="field" placeholder="INV-2026-001" />
		</label>
		<label class="space-y-2">
			<span class="text-sm font-medium text-slate-200">Mata uang</span>
			<select bind:value={form.currency} class="field">
				<option value="IDR">IDR</option>
				<option value="USD">USD</option>
				<option value="SGD">SGD</option>
			</select>
		</label>
		<label class="space-y-2">
			<span class="text-sm font-medium text-slate-200">Tanggal terbit</span>
			<input bind:value={form.issueDate} class="field" type="date" />
		</label>
		<label class="space-y-2">
			<span class="text-sm font-medium text-slate-200">Jatuh tempo</span>
			<input bind:value={form.dueDate} class="field" type="date" />
		</label>
	</div>

	<div class="grid gap-8 xl:grid-cols-2">
		<div class="space-y-4">
			<div class="space-y-1">
				<h2 class="text-sm font-semibold tracking-[0.22em] text-slate-400 uppercase">Pengirim</h2>
				<p class="text-sm text-slate-500">Informasi bisnis atau freelancer.</p>
			</div>
			<div class="grid gap-4">
				<label class="space-y-2">
					<span class="text-sm font-medium text-slate-200">Nama</span>
					<input bind:value={form.fromName} class="field" placeholder="Studio Arunika" />
				</label>
				<label class="space-y-2">
					<span class="text-sm font-medium text-slate-200">Email</span>
					<input
						bind:value={form.fromEmail}
						class="field"
						placeholder="halo@arunika.id"
						type="email"
					/>
				</label>
				<div class="grid gap-4 sm:grid-cols-2">
					<label class="space-y-2">
						<span class="text-sm font-medium text-slate-200">Telepon</span>
						<input bind:value={form.fromPhone} class="field" placeholder="0812 0000 0000" />
					</label>
					<label class="space-y-2">
						<span class="text-sm font-medium text-slate-200">Alamat</span>
						<input bind:value={form.fromAddress} class="field" placeholder="Jakarta, Indonesia" />
					</label>
				</div>
			</div>
		</div>

		<div class="space-y-4">
			<div class="space-y-1">
				<h2 class="text-sm font-semibold tracking-[0.22em] text-slate-400 uppercase">Klien</h2>
				<p class="text-sm text-slate-500">Data penerima invoice.</p>
			</div>
			<div class="grid gap-4">
				<label class="space-y-2">
					<span class="text-sm font-medium text-slate-200">Nama</span>
					<input bind:value={form.clientName} class="field" placeholder="PT Sinar Utama" />
				</label>
				<label class="space-y-2">
					<span class="text-sm font-medium text-slate-200">Email</span>
					<input
						bind:value={form.clientEmail}
						class="field"
						placeholder="finance@sinarutama.co.id"
						type="email"
					/>
				</label>
				<div class="grid gap-4 sm:grid-cols-2">
					<label class="space-y-2">
						<span class="text-sm font-medium text-slate-200">Telepon</span>
						<input bind:value={form.clientPhone} class="field" placeholder="021 5555 9999" />
					</label>
					<label class="space-y-2">
						<span class="text-sm font-medium text-slate-200">Alamat</span>
						<input bind:value={form.clientAddress} class="field" placeholder="Bandung, Indonesia" />
					</label>
				</div>
			</div>
		</div>
	</div>

	<div class="space-y-4">
		<div class="flex items-center justify-between gap-4">
			<div class="space-y-1">
				<h2 class="text-sm font-semibold tracking-[0.22em] text-slate-400 uppercase">
					Item tagihan
				</h2>
				<p class="text-sm text-slate-500">Tambahkan layanan atau produk seperlunya.</p>
			</div>
			<button class="button-secondary" type="button" onclick={onAddItem}>Tambah item</button>
		</div>

		<div class="overflow-hidden rounded-3xl border border-white/10">
			<div
				class="hidden grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] gap-3 border-b border-white/10 bg-white/3 px-4 py-3 text-xs font-semibold tracking-[0.18em] text-slate-400 uppercase sm:grid"
			>
				<span>Deskripsi</span>
				<span>Qty</span>
				<span>Harga</span>
				<span></span>
			</div>
			<div class="divide-y divide-white/10">
				{#each items as item (item.id)}
					<div
						class="grid gap-3 px-4 py-4 sm:grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] sm:items-center"
					>
						<input
							bind:value={item.description}
							class="field"
							placeholder="UI design, development, konsultasi"
						/>
						<input bind:value={item.quantity} class="field" min="1" type="number" />
						<input
							class="field"
							inputmode="numeric"
							placeholder="4.500.000"
							type="text"
							value={getPriceInputValue(item)}
							onblur={() => handlePriceBlur(item)}
							onfocus={() => handlePriceFocus(item)}
							oninput={(event) => handlePriceInput(item, event)}
						/>
						<button
							aria-label="Hapus item"
							class="button-icon"
							type="button"
							onclick={() => onRemoveItem(item.id)}
						>
							×
						</button>
					</div>
				{/each}
			</div>
		</div>
	</div>

	<label class="space-y-2">
		<span class="text-sm font-medium text-slate-200">Catatan</span>
		<textarea
			bind:value={form.notes}
			class="field min-h-28 resize-y"
			placeholder="Terima kasih atas kerja samanya. Pembayaran dapat dilakukan sesuai detail yang tertera."
		></textarea>
	</label>
</section>
