<script lang="ts">
	import type { InvoiceFormData, InvoiceItem } from '$lib/types/invoice';
	import Select from '$lib/components/ui/Select.svelte';
	import DatePicker from '$lib/components/ui/DatePicker.svelte';

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

	function handleQuantityBlur(item: InvoiceItem, event: Event) {
		const input = event.currentTarget as HTMLInputElement;
		const quantity = Number(input.value);
		const normalizedQuantity =
			Number.isFinite(quantity) && quantity >= 1 ? Math.floor(quantity) : 1;

		item.quantity = normalizedQuantity;
		input.value = String(normalizedQuantity);
	}

	function handlePriceBlur(item: InvoiceItem) {
		focusedPriceInputs[item.id] = false;
		priceDrafts[item.id] = formatPrice(item.unitPrice);
	}

	function handleBankAccountFormat(event: Event) {
		const input = event.currentTarget as HTMLInputElement;
		const rawValue = input.value.replace(/\D/g, '');
		const formatted = rawValue.replace(/(.{4})/g, '$1 ').trim();
		form.bankAccount = formatted;
		input.value = formatted;
	}
</script>

<div class="hidden lg:block">
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
		<label class="space-y-2 relative z-30">
			<span class="text-sm font-medium text-slate-200">Mata uang</span>
			<Select bind:value={form.currency} options={[
				{value: 'IDR', label: 'IDR - Rupiah'},
				{value: 'USD', label: 'USD - US Dollar'},
				{value: 'SGD', label: 'SGD - Singapore Dollar'}
			]} />
		</label>
		<label class="space-y-2 relative z-20">
			<span class="text-sm font-medium text-slate-200">Tanggal terbit</span>
			<DatePicker bind:value={form.issueDate} align="left" />
		</label>
		<label class="space-y-2 relative z-10">
			<span class="text-sm font-medium text-slate-200">Jatuh tempo</span>
			<DatePicker bind:value={form.dueDate} align="right" />
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
		<div class="space-y-1">
			<h2 class="text-sm font-semibold tracking-[0.22em] text-slate-400 uppercase">Metode Pembayaran</h2>
			<p class="text-sm text-slate-500">Detail bank atau tujuan transfer.</p>
		</div>
		<div class="grid gap-4 sm:grid-cols-3">
			<label class="space-y-2">
				<span class="text-sm font-medium text-slate-200">Nama Bank</span>
				<input bind:value={form.bankName} class="field" placeholder="BCA" />
			</label>
			<label class="space-y-2">
				<span class="text-sm font-medium text-slate-200">No. Rekening</span>
				<input bind:value={form.bankAccount} class="field" placeholder="1234 5678 910" type="text" inputmode="numeric" onblur={handleBankAccountFormat} />
			</label>
			<label class="space-y-2">
				<span class="text-sm font-medium text-slate-200">Atas Nama</span>
				<input bind:value={form.bankAccountName} class="field" placeholder="PT Studio Arunika" />
			</label>
		</div>
	</div>

<div class="space-y-4">
		<div class="space-y-1">
			<h2 class="text-sm font-semibold tracking-[0.22em] text-slate-400 uppercase">Item tagihan</h2>
			<p class="text-sm text-slate-500">Tambahkan layanan atau produk seperlunya.</p>
		</div>

		<div
			class="space-y-3 sm:space-y-0 sm:overflow-hidden sm:rounded-3xl sm:border sm:border-white/10"
		>
			<div
				class="hidden grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] gap-3 border-b border-white/10 bg-white/3 px-4 py-3 text-xs font-semibold tracking-[0.18em] text-slate-400 uppercase sm:grid"
			>
				<span>Deskripsi</span>
				<span>Qty</span>
				<span>Harga</span>
				<span></span>
			</div>
			<div class="space-y-3 sm:space-y-0 sm:divide-y sm:divide-white/10">
				{#each items as item (item.id)}
					<div class="space-y-3 rounded-2xl border border-white/10 bg-white/3 p-4 sm:hidden">
						<label class="space-y-2">
							<span class="text-xs font-medium text-slate-400">Deskripsi</span>
							<input
								bind:value={item.description}
								class="field"
								placeholder="UI design, development, konsultasi"
							/>
						</label>
						<div class="grid grid-cols-2 gap-3">
							<label class="space-y-2">
								<span class="text-xs font-medium text-slate-400">Qty</span>
								<input
									bind:value={item.quantity}
									class="field"
									min="1"
									type="number"
									onblur={(event) => handleQuantityBlur(item, event)}
								/>
							</label>
							<label class="space-y-2">
								<span class="text-xs font-medium text-slate-400">Harga</span>
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
							</label>
						</div>
						<button
							aria-label="Hapus item"
							class="button-secondary w-full justify-center text-rose-300 hover:border-rose-400/40 hover:bg-rose-400/10"
							type="button"
							onclick={() => onRemoveItem(item.id)}
						>
							Hapus item
						</button>
					</div>
					<div
						class="hidden grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] gap-3 px-4 py-4 sm:grid sm:items-center"
					>
						<input
							bind:value={item.description}
							class="field"
							placeholder="UI design, development, konsultasi"
						/>
						<input
							bind:value={item.quantity}
							class="field"
							min="1"
							type="number"
							onblur={(event) => handleQuantityBlur(item, event)}
						/>
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

		<button
			class="button-secondary w-full justify-center sm:w-auto"
			type="button"
			onclick={onAddItem}
		>
			Tambah item
		</button>
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
</div>

<div class="block lg:hidden">
<div class="space-y-6 sm:space-y-8">
	<header class="space-y-2 px-2 sm:px-0">
		<p class="text-xs font-medium tracking-[0.28em] text-cyan-400 uppercase">Formulir Tagihan</p>
		<h1 class="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
			Buat Invoice Profesional
		</h1>
		<p class="max-w-2xl text-sm leading-6 text-slate-400 sm:text-[15px]">
			Masukkan detail tagihan Anda. Tampilan PDF akan diperbarui secara otomatis.
		</p>
	</header>

	<section class="rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl backdrop-blur sm:p-8 space-y-6">
		<div class="flex items-center gap-3 border-b border-white/5 pb-4">
			<div class="flex h-8 w-8 items-center justify-center rounded-full bg-cyan-500/20 text-cyan-400 font-bold">
				1
			</div>
			<h2 class="text-sm font-semibold tracking-[0.22em] text-white uppercase">Informasi Dasar</h2>
		</div>
		
		<div class="grid gap-5 sm:grid-cols-2">
			<label class="space-y-2">
				<span class="text-sm font-medium text-slate-300">Nomor Invoice</span>
				<input bind:value={form.invoiceNumber} class="field" placeholder="INV-2026-001" />
			</label>
			<label class="space-y-2">
				<span class="text-sm font-medium text-slate-300">Mata Uang</span>
				<Select bind:value={form.currency} options={[
					{value: 'IDR', label: 'IDR - Rupiah'},
					{value: 'USD', label: 'USD - US Dollar'},
					{value: 'SGD', label: 'SGD - Singapore Dollar'}
				]} />
			</label>
			<label class="space-y-2 relative z-20">
				<span class="text-sm font-medium text-slate-300">Tanggal Terbit</span>
				<DatePicker bind:value={form.issueDate} align="left" />
			</label>
			<label class="space-y-2 relative z-10">
				<span class="text-sm font-medium text-slate-300">Jatuh Tempo</span>
				<DatePicker bind:value={form.dueDate} align="right" />
			</label>
		</div>
	</section>

	<section class="rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl backdrop-blur sm:p-8 space-y-6">
		<div class="flex items-center gap-3 border-b border-white/5 pb-4">
			<div class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-500/20 text-indigo-400 font-bold">
				2
			</div>
			<h2 class="text-sm font-semibold tracking-[0.22em] text-white uppercase">Identitas</h2>
		</div>
		
		<div class="grid gap-6 xl:grid-cols-2">
			<div class="space-y-5 rounded-2xl bg-black/20 p-5 sm:p-6 border border-white/5 relative overflow-hidden">
				<div class="absolute top-0 left-0 w-1 h-full bg-cyan-500"></div>
				<h3 class="text-xs font-bold tracking-[0.2em] text-cyan-400 uppercase">Data Pengirim</h3>
				<div class="space-y-4">
					<label class="space-y-1.5 block">
						<span class="text-xs font-medium text-slate-400">Nama Bisnis</span>
						<input bind:value={form.fromName} class="field" placeholder="Studio Arunika" />
					</label>
					<label class="space-y-1.5 block">
						<span class="text-xs font-medium text-slate-400">Email</span>
						<input bind:value={form.fromEmail} class="field" placeholder="halo@arunika.id" type="email" />
					</label>
					<div class="grid gap-4 sm:grid-cols-2">
						<label class="space-y-1.5 block">
							<span class="text-xs font-medium text-slate-400">Telepon</span>
							<input bind:value={form.fromPhone} class="field" placeholder="0812 0000 0000" />
						</label>
						<label class="space-y-1.5 block">
							<span class="text-xs font-medium text-slate-400">Alamat</span>
							<input bind:value={form.fromAddress} class="field" placeholder="Jakarta, Indonesia" />
						</label>
					</div>
				</div>
			</div>

			<div class="space-y-5 rounded-2xl bg-black/20 p-5 sm:p-6 border border-white/5 relative overflow-hidden">
				<div class="absolute top-0 left-0 w-1 h-full bg-indigo-500"></div>
				<h3 class="text-xs font-bold tracking-[0.2em] text-indigo-400 uppercase">Data Klien</h3>
				<div class="space-y-4">
					<label class="space-y-1.5 block">
						<span class="text-xs font-medium text-slate-400">Nama Klien</span>
						<input bind:value={form.clientName} class="field" placeholder="PT Sinar Utama" />
					</label>
					<label class="space-y-1.5 block">
						<span class="text-xs font-medium text-slate-400">Email</span>
						<input bind:value={form.clientEmail} class="field" placeholder="finance@sinarutama.co.id" type="email" />
					</label>
					<div class="grid gap-4 sm:grid-cols-2">
						<label class="space-y-1.5 block">
							<span class="text-xs font-medium text-slate-400">Telepon</span>
							<input bind:value={form.clientPhone} class="field" placeholder="021 5555 9999" />
						</label>
						<label class="space-y-1.5 block">
							<span class="text-xs font-medium text-slate-400">Alamat</span>
							<input bind:value={form.clientAddress} class="field" placeholder="Bandung, Indonesia" />
						</label>
					</div>
				</div>
			</div>
		</div>
	</section>

	<section class="rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl backdrop-blur sm:p-8 space-y-6">
		<div class="flex items-center gap-3 border-b border-white/5 pb-4">
			<div class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-400 font-bold">
				3
			</div>
			<h2 class="text-sm font-semibold tracking-[0.22em] text-white uppercase">Metode Pembayaran</h2>
		</div>
		
		<div class="grid gap-5 sm:grid-cols-2">
			<label class="space-y-2 block">
				<span class="text-sm font-medium text-slate-300">Nama Bank</span>
				<input bind:value={form.bankName} class="field" placeholder="BCA" />
			</label>
			<label class="space-y-2 block">
				<span class="text-sm font-medium text-slate-300">No. Rekening</span>
				<input bind:value={form.bankAccount} class="field" placeholder="1234 5678 910" type="text" inputmode="numeric" onblur={handleBankAccountFormat} />
			</label>
			<label class="space-y-2 block sm:col-span-2">
				<span class="text-sm font-medium text-slate-300">Atas Nama</span>
				<input bind:value={form.bankAccountName} class="field" placeholder="PT Studio Arunika" />
			</label>
		</div>
	</section>

	<section class="rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl backdrop-blur sm:p-8 space-y-6">
		<div class="flex items-center justify-between border-b border-white/5 pb-4">
			<div class="flex items-center gap-3">
				<div class="flex h-8 w-8 items-center justify-center rounded-full bg-rose-500/20 text-rose-400 font-bold">
					4
				</div>
				<h2 class="text-sm font-semibold tracking-[0.22em] text-white uppercase">Item Tagihan</h2>
			</div>
		</div>

		<div class="space-y-4">
			<div class="space-y-4 sm:space-y-0 sm:overflow-hidden sm:rounded-[20px] sm:border sm:border-white/10">
				<div class="hidden grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] gap-3 border-b border-white/10 bg-black/20 px-4 py-3 text-xs font-semibold tracking-[0.18em] text-slate-400 uppercase sm:grid">
					<span>Deskripsi</span>
					<span>Qty</span>
					<span>Harga</span>
					<span></span>
				</div>
				
				<div class="space-y-4 sm:space-y-0 sm:divide-y sm:divide-white/10">
					{#each items as item (item.id)}
						<div class="space-y-4 rounded-2xl border border-white/10 bg-black/20 p-5 sm:hidden relative overflow-hidden">
							<div class="absolute top-0 left-0 w-1 h-full bg-emerald-500/50"></div>
							<label class="flex flex-col gap-1.5">
								<span class="text-[11px] font-bold tracking-widest text-slate-500 uppercase">Deskripsi</span>
								<input bind:value={item.description} class="field" placeholder="UI design, development..." />
							</label>
							<div class="grid grid-cols-2 gap-4">
								<label class="flex flex-col gap-1.5">
									<span class="text-[11px] font-bold tracking-widest text-slate-500 uppercase">Qty</span>
									<input bind:value={item.quantity} class="field" min="1" type="number" onblur={(e) => handleQuantityBlur(item, e)} />
								</label>
								<label class="flex flex-col gap-1.5">
									<span class="text-[11px] font-bold tracking-widest text-slate-500 uppercase">Harga</span>
									<input class="field" inputmode="numeric" placeholder="4.500.000" type="text" value={getPriceInputValue(item)} onblur={() => handlePriceBlur(item)} onfocus={() => handlePriceFocus(item)} oninput={(e) => handlePriceInput(item, e)} />
								</label>
							</div>
							<button class="button-secondary w-full justify-center text-rose-300 hover:border-rose-400/40 hover:bg-rose-400/10 mt-2" type="button" onclick={() => onRemoveItem(item.id)}>
								Hapus Item
							</button>
						</div>
						
						<div class="hidden grid-cols-[minmax(0,1.8fr)_0.8fr_1fr_56px] gap-3 px-4 py-4 sm:grid sm:items-center bg-white/0 hover:bg-white/5 transition-colors">
							<input bind:value={item.description} class="field" placeholder="UI design, development, konsultasi" />
							<input bind:value={item.quantity} class="field" min="1" type="number" onblur={(e) => handleQuantityBlur(item, e)} />
							<input class="field" inputmode="numeric" placeholder="4.500.000" type="text" value={getPriceInputValue(item)} onblur={() => handlePriceBlur(item)} onfocus={() => handlePriceFocus(item)} oninput={(e) => handlePriceInput(item, e)} />
							<button aria-label="Hapus item" class="button-icon hover:bg-rose-500/20 hover:text-rose-400" type="button" onclick={() => onRemoveItem(item.id)}>
								×
							</button>
						</div>
					{/each}
				</div>
			</div>

			<button class="w-full cursor-pointer flex items-center justify-center gap-2 rounded-[20px] border border-dashed border-white/20 bg-white/5 hover:bg-white/10 p-4 text-sm font-semibold text-white transition-all sm:w-auto px-8" type="button" onclick={onAddItem}>
				+ Tambah Baris Baru
			</button>
		</div>
	</section>



	<section class="rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl backdrop-blur sm:p-8 space-y-6">
		<div class="flex items-center gap-3 border-b border-white/5 pb-4">
			<div class="flex h-8 w-8 items-center justify-center rounded-full bg-amber-500/20 text-amber-400 font-bold">
				5
			</div>
			<h2 class="text-sm font-semibold tracking-[0.22em] text-white uppercase">Catatan Tambahan</h2>
		</div>
		<textarea bind:value={form.notes} class="field min-h-28 w-full resize-y" placeholder="Terima kasih atas kerja samanya. Pembayaran dapat dilakukan sesuai detail yang tertera."></textarea>
	</section>
</div>
</div>
