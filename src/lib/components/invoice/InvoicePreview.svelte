<script lang="ts">
	import { tick } from 'svelte';
	import type { InvoiceFormData, InvoiceItem } from '$lib/types/invoice';

	type Props = {
		form: InvoiceFormData;
		items: InvoiceItem[];
		subtotal: number;
		discountAmount: number;
		taxRate: number;
		taxAmount: number;
		total: number;
		formatCurrency: (value: number) => string;
		formatDate: (value: string) => string;
	};

	let { form, items, subtotal, discountAmount, taxRate, taxAmount, total, formatCurrency, formatDate }: Props =
		$props();

	let isGeneratingPdf = $state(false);
	let downloadError = $state<string | null>(null);
	let previewWrapperWidth = $state(0);
	let currentPageIndex = $state(0);
	
	$effect(() => {
		if (currentPageIndex >= invoicePages.length && invoicePages.length > 0) {
			currentPageIndex = invoicePages.length - 1;
		}
	});
	
	let scale = $derived(previewWrapperWidth > 0 && previewWrapperWidth < 820 ? previewWrapperWidth / 820 : 1);
	const invoicePages = $derived.by(() => {
		const pages = [];
		let remaining = [...items];
		let pageIndex = 0;
		let hasFooter = false;
		let currentGlobalIndex = 0;

		if (remaining.length === 0) {
			return [{ pageItems: [], isFirst: true, isLast: true, pageNumber: 1, startIndex: 0 }];
		}

		while (!hasFooter) {
			let isFirst = pageIndex === 0;
			let maxWithFooter = isFirst ? 5 : 8;
			let maxNoFooter = isFirst ? 8 : 11;

			if (remaining.length <= maxWithFooter) {
				pages.push({ 
					pageItems: remaining.splice(0, remaining.length), 
					isFirst, 
					isLast: true,
					pageNumber: pageIndex + 1,
					startIndex: currentGlobalIndex
				});
				hasFooter = true;
			} else {
				let taken = remaining.splice(0, maxNoFooter);
				pages.push({ 
					pageItems: taken, 
					isFirst, 
					isLast: false,
					pageNumber: pageIndex + 1,
					startIndex: currentGlobalIndex
				});
				currentGlobalIndex += taken.length;
			}
			pageIndex++;
		}
		return pages;
	});

	let totalHeight = $derived(
		isGeneratingPdf 
			? invoicePages.length * 1123 + Math.max(0, invoicePages.length - 1) * 32 
			: 1123
	);

	async function handleDownloadPdf() {
		if (typeof window === 'undefined') return;
		
		isGeneratingPdf = true;
		downloadError = null;
		
		await tick();
		await new Promise(r => setTimeout(r, 100)); // wait for DOM reflow

		try {
			const { toPng } = await import('html-to-image');
			const { jsPDF } = await import('jspdf');
			
			const pdf = new jsPDF({
				orientation: 'portrait',
				unit: 'mm',
				format: 'a4'
			});

			for (let i = 0; i < invoicePages.length; i++) {
				const element = document.getElementById(`printable-page-${i + 1}`);
				if (!element) throw new Error("Invoice page element not found");

				const originalTransform = element.style.transform;
				element.style.transform = 'none';

				const imgData = await toPng(element, {
					quality: 0.98,
					pixelRatio: 2,
					backgroundColor: '#ffffff',
					width: 794,
					height: 1123,
					style: {
						width: '794px',
						height: '1123px',
						maxWidth: '794px',
						margin: '0',
						transform: 'none'
					}
				});

				element.style.transform = originalTransform;

				const pdfWidth = pdf.internal.pageSize.getWidth();
				const pdfHeight = pdf.internal.pageSize.getHeight();

				if (i > 0) {
					pdf.addPage();
				}

				pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
			}

			const filename = form.invoiceNumber && form.clientName 
				? `${form.invoiceNumber} - ${form.clientName}.pdf` 
				: 'Invoice.pdf';

			pdf.save(filename);
		} catch (error) {
			console.error("Gagal membuat PDF:", error);
			downloadError = "Terjadi kesalahan saat membuat PDF. Silakan coba lagi.";
		} finally {
			isGeneratingPdf = false;
		}
	}
</script>

<div class="space-y-4 pb-20 flex flex-col w-full items-center">
	{#if downloadError}
		<p class="text-sm text-red-400 w-full text-center">{downloadError}</p>
	{/if}

	<div class="relative w-full max-w-[820px] mx-auto flex flex-col items-center" bind:clientWidth={previewWrapperWidth}>
		<!-- Navigation Buttons (Desktop) -->
		{#if invoicePages.length > 1 && !isGeneratingPdf}
			<button
				class="absolute left-[-20px] top-1/2 -translate-y-1/2 z-50 flex h-12 w-12 items-center justify-center rounded-full bg-white text-[#1363a6] shadow-xl transition-all hover:scale-110 hover:bg-[#1363a6] hover:text-white disabled:opacity-30 disabled:pointer-events-none"
				onclick={() => currentPageIndex = Math.max(0, currentPageIndex - 1)}
				disabled={currentPageIndex === 0}
				aria-label="Halaman Sebelumnya"
			>
				<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M15 19l-7-7 7-7"></path></svg>
			</button>

			<button
				class="absolute right-[-20px] top-1/2 -translate-y-1/2 z-50 flex h-12 w-12 items-center justify-center rounded-full bg-white text-[#1363a6] shadow-xl transition-all hover:scale-110 hover:bg-[#1363a6] hover:text-white disabled:opacity-30 disabled:pointer-events-none"
				onclick={() => currentPageIndex = Math.min(invoicePages.length - 1, currentPageIndex + 1)}
				disabled={currentPageIndex === invoicePages.length - 1}
				aria-label="Halaman Selanjutnya"
			>
				<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7"></path></svg>
			</button>
		{/if}

		<div 
			class="relative w-[794px] {isGeneratingPdf ? '' : 'overflow-hidden rounded-xl shadow-2xl'}"
			style="transform: scale({scale}); transform-origin: top center; margin-bottom: {totalHeight * (scale - 1)}px; height: {totalHeight}px;"
		>
			<div 
				id="invoice-pdf-container" 
				class="{isGeneratingPdf ? 'flex flex-col gap-8' : 'flex h-full transition-transform duration-700 ease-[cubic-bezier(0.25,1,0.5,1)]'}"
				style="{isGeneratingPdf ? '' : `width: ${invoicePages.length * 100}%; transform: translateX(-${(currentPageIndex * 100) / invoicePages.length}%);`}"
			>
				{#each invoicePages as page (page.pageNumber)}
					<div class="{isGeneratingPdf ? '' : 'shrink-0 flex justify-center'}" style="{isGeneratingPdf ? '' : `width: ${100 / invoicePages.length}%;`}">
						<div id="printable-page-{page.pageNumber}" class="bg-white text-slate-800 relative print:m-0 print:shadow-none print:overflow-visible {isGeneratingPdf ? 'shadow-2xl' : ''} w-[794px] h-[1123px] shrink-0 flex flex-col font-sans box-border overflow-hidden print:break-after-page">
					
				{#if page.isFirst}
					<!-- Top Banner -->
					<div class="relative w-full h-[140px] bg-[#1363a6] flex items-center overflow-hidden shrink-0" style="-webkit-print-color-adjust: exact;">
						<!-- Diagonal background stripes in blue area -->
						<div class="absolute right-[20%] top-0 w-2 h-full bg-white/20 skew-x-[30deg]"></div>
						<div class="absolute right-[18%] top-0 w-8 h-full bg-white/10 skew-x-[30deg]"></div>
						
						<!-- Black shape on the left -->
						<div class="absolute left-[-50px] top-0 bottom-0 w-[55%] bg-[#0a0a0a] skew-x-[30deg] origin-top-left z-10"></div>
						<!-- Thin blue border effect next to black -->
						<div class="absolute left-[-45px] top-0 bottom-0 w-[55%] bg-[#3b82f6] skew-x-[30deg] origin-top-left z-0"></div>

						<!-- Left Content (over black) -->
						<div class="relative z-20 w-[60%] pl-12 pr-4 flex flex-col justify-center">
							<div class="flex flex-col justify-center">
								<h1 class="text-[30px] font-black text-white leading-tight tracking-wide whitespace-nowrap">
									<span class="text-[#3b82f6] text-[44px] italic mr-[1px]">{form.fromName ? form.fromName.charAt(0).toUpperCase() : 'C'}</span>{form.fromName ? form.fromName.slice(1) : 'OMPANY'}
								</h1>
								<p class="text-white/70 text-[12px] tracking-[0.3em] font-bold uppercase mt-1">COMPANY</p>
							</div>
						</div>

						<!-- Right Content (over blue) -->
						<div class="relative z-20 w-[40%] pr-12 pl-4 flex flex-col justify-center items-end text-right">
							<h2 class="text-4xl font-black text-white tracking-widest mb-3">INVOICE</h2>
							<table class="text-[10px] text-white">
								<tbody>
									<tr><td class="pr-6 pb-0.5 font-bold text-white/90">Nomor Invoice:</td><td class="pb-0.5 text-right">{form.invoiceNumber || '#123456'}</td></tr>
									<tr><td class="pr-6 pb-0.5 font-bold text-white/90">Tanggal Invoice:</td><td class="pb-0.5 text-right">{form.issueDate ? formatDate(form.issueDate) : 'April 05, 2026'}</td></tr>
									<tr><td class="pr-6 pb-0.5 font-bold text-white/90">Nomor Telepon:</td><td class="pb-0.5 text-right">{form.fromPhone || '+123 4567 8910'}</td></tr>
									<tr><td class="pr-6 pb-0.5 font-bold text-white/90">Email:</td><td class="pb-0.5 text-right">{form.fromEmail || 'example@mail.com'}</td></tr>
								</tbody>
							</table>
						</div>
					</div>

					<!-- Invoice To & Metode Pembayaran -->
					<div class="px-12 pt-8 grid grid-cols-2 gap-8 shrink-0">
						<div>
							<h3 class="text-[#1363a6] font-bold text-[11px] tracking-wide mb-2 uppercase">DITAGIHKAN KEPADA:</h3>
							<p class="text-[22px] font-bold text-slate-900 leading-none mb-2">{form.clientName || 'Nama Pelanggan'}</p>
							<p class="text-[11px] text-slate-600 mb-3">{form.clientAddress || 'Alamat Pelanggan'}</p>
							<p class="text-[11px] font-bold text-slate-800 mb-0.5">Telepon: <span class="font-normal text-slate-600 ml-1">{form.clientPhone || '+123 4567 8910'}</span></p>
							<p class="text-[11px] font-bold text-slate-800">Email: <span class="font-normal text-slate-600 ml-1">{form.clientEmail || 'example@mail.com'}</span></p>
						</div>
						<div>
							<h3 class="text-[#1363a6] font-bold text-[11px] tracking-wide mb-2 uppercase">Metode Pembayaran:</h3>
							<table class="text-[11px] text-slate-700 w-full">
								<tbody>
									<tr><td class="font-bold py-0.5 w-24 text-slate-800">No. Rekening:</td><td class="py-0.5 text-slate-600">{form.bankAccount || '1234 5678 910'}</td></tr>
									<tr><td class="font-bold py-0.5 text-slate-800">Atas Nama:</td><td class="py-0.5 text-slate-600">{form.bankAccountName || 'Nama Pemilik Rekening'}</td></tr>
									<tr><td class="font-bold py-0.5 text-slate-800">Nama Bank:</td><td class="py-0.5 text-slate-600">{form.bankName || 'Nama Bank'}</td></tr>
								</tbody>
							</table>
						</div>
					</div>

					<!-- Dear Client -->
					<div class="px-12 pt-8 shrink-0">
						<p class="text-[12px] font-bold text-slate-900 mb-2">Yth. Pelanggan</p>
						<p class="text-[11px] text-slate-600 leading-[1.6] text-justify">
							Berikut adalah rincian tagihan atas produk/layanan yang telah kami berikan. Harap memeriksa rincian di bawah ini dengan saksama. Jika terdapat pertanyaan atau ketidaksesuaian, jangan ragu untuk menghubungi kami melalui kontak yang tertera di atas.
						</p>
					</div>
				{/if}

				{#if !page.isFirst}
					<div class="w-full h-[60px] bg-[#1363a6] shrink-0 mb-8 px-12 flex justify-between items-center text-white" style="-webkit-print-color-adjust: exact;">
						<h2 class="text-xl font-black tracking-widest">INVOICE</h2>
						<div class="text-right text-[11px]">
							<p class="font-bold">{form.invoiceNumber || '#123456'}</p>
							<p>{form.clientName || 'Nama Pelanggan'}</p>
						</div>
					</div>
				{/if}

				<!-- Table -->
				<div class="px-12 pt-8 flex-grow">
					<table class="w-full text-left border-collapse" style="-webkit-print-color-adjust: exact;">
						<thead>
							<tr>
								<th class="w-[8%] p-0">
									<div class="bg-[#1363a6] text-white py-2.5 text-center skew-x-[-25deg] ml-[-12px] mr-[2px]">
										<span class="block skew-x-[25deg] text-[11px]">No.</span>
									</div>
								</th>
								<th class="w-[42%] p-0">
									<div class="bg-[#1363a6] text-white py-2.5 text-left pl-6 skew-x-[-25deg] mx-[2px]">
										<span class="block skew-x-[25deg] text-[11px]">Deskripsi Produk</span>
									</div>
								</th>
								<th class="w-[15%] p-0">
									<div class="bg-[#1363a6] text-white py-2.5 text-center skew-x-[-25deg] mx-[2px]">
										<span class="block skew-x-[25deg] text-[11px]">Harga</span>
									</div>
								</th>
								<th class="w-[15%] p-0">
									<div class="bg-[#1363a6] text-white py-2.5 text-center skew-x-[-25deg] mx-[2px]">
										<span class="block skew-x-[25deg] text-[11px]">Jumlah</span>
									</div>
								</th>
								<th class="w-[20%] p-0">
									<div class="bg-[#1363a6] text-white py-2.5 text-center skew-x-[-25deg] ml-[2px] mr-[-12px]">
										<span class="block skew-x-[25deg] text-[11px]">Total</span>
									</div>
								</th>
							</tr>
						</thead>
						<tbody>
							{#each page.pageItems as item, idx (item.id)}
								<tr class="border-b border-slate-200/60">
									<td class="py-4 px-2 text-[11px] text-slate-500 text-center font-medium">{String(page.startIndex + idx + 1).padStart(2, '0')}</td>
									<td class="py-4 px-4">
										<p class="text-[12px] font-bold text-slate-800">{item.description || '-'}</p>
										<p class="text-[10px] text-slate-400 mt-1 italic leading-relaxed"></p>
									</td>
									<td class="py-4 px-2 text-[11px] text-slate-600 text-center font-medium">{formatCurrency(item.unitPrice)}</td>
									<td class="py-4 px-2 text-[11px] text-slate-600 text-center font-medium">{item.quantity}</td>
									<td class="py-4 px-2 text-[11px] text-slate-800 text-right pr-4 font-bold">{formatCurrency(item.quantity * item.unitPrice)}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>

				{#if page.isLast}
					<!-- Summary Section -->
					<div class="px-12 flex justify-between items-start mb-[140px] mt-4 shrink-0" style="-webkit-print-color-adjust: exact;">
						<div class="w-[50%] pr-8">
							<h3 class="text-[#1363a6] font-bold text-[12px] mb-2">Catatan:</h3>
							<p class="text-[10px] text-slate-500 leading-relaxed text-justify whitespace-pre-wrap">{form.notes || 'Pembayaran harap dilakukan penuh sesuai nominal yang tertera pada invoice ini sebelum tanggal jatuh tempo.\n\nKeterlambatan pembayaran dapat dikenakan denda sesuai dengan kebijakan perusahaan. Terima kasih.'}</p>
						</div>
						
						<div class="w-[45%] pl-4 pt-2">
							<table class="w-full text-[11px] text-slate-700">
								<tbody>
									<tr>
										<td class="py-1 text-right pr-12">Subtotal:</td>
										<td class="py-1 text-right font-bold text-slate-900">{formatCurrency(subtotal)}</td>
									</tr>
									{#if form.discount > 0}
									<tr>
										<td class="py-1 text-right pr-12">Diskon ({form.discount}%):</td>
										<td class="py-1 text-right font-bold text-rose-600">-{formatCurrency(discountAmount)}</td>
									</tr>
									{/if}
									<tr>
										<td class="py-1 text-right pr-12">Pajak ({taxRate}%):</td>
										<td class="py-1 text-right font-bold text-slate-900">{formatCurrency(taxAmount)}</td>
									</tr>
								</tbody>
							</table>
							
							<!-- Total Block -->
							<div class="mt-4 bg-[#1363a6] text-white flex justify-between items-center py-3 pl-8 pr-4 relative">
								<div class="absolute left-[-15px] top-0 bottom-0 w-8 bg-[#1363a6] skew-x-[-25deg]"></div>
								<span class="font-bold relative z-10 text-[13px]">Total:</span>
								<span class="font-bold relative z-10 text-[14px] tracking-wide">{formatCurrency(total)}</span>
							</div>
						</div>
					</div>

					<!-- Footer -->
					<div class="absolute bottom-0 left-0 w-full h-32 flex items-end justify-between overflow-hidden shrink-0" style="-webkit-print-color-adjust: exact;">
						<!-- Bottom Left Slanted shape -->
						<div class="absolute left-[-100px] bottom-0 w-[400px] h-10 bg-[#1363a6] skew-x-[45deg] origin-bottom-left"></div>
						
						<div class="relative z-10 pl-12 pb-10">

						</div>
					</div>
				{/if}

				{#if invoicePages.length > 1}
					<div class="absolute bottom-4 left-1/2 -translate-x-1/2 text-center text-[10px] text-slate-400 font-medium tracking-widest print:hidden">
						Halaman {page.pageNumber} dari {invoicePages.length}
					</div>
				{/if}
			</div>
			</div>
		{/each}
		</div>
	</div>
	
	<!-- Page Indicators -->
	{#if invoicePages.length > 1 && !isGeneratingPdf}
		<div class="flex gap-2 justify-center w-full relative z-10 pt-2">
			{#each invoicePages as page (page.pageNumber)}
				<button 
					class="h-2 rounded-full transition-all duration-300 {currentPageIndex === (page.pageNumber - 1) ? 'w-6 bg-[#1363a6]' : 'w-2 bg-slate-300 hover:bg-slate-400'}"
					onclick={() => currentPageIndex = (page.pageNumber - 1)}
					aria-label="Ke halaman {page.pageNumber}"
				></button>
			{/each}
		</div>
	{/if}
	</div>

	<div class="mt-4 flex w-full max-w-[794px] flex-col print:hidden px-4 sm:px-0">
		<button
			disabled={isGeneratingPdf}
			class="w-full cursor-pointer flex items-center justify-center gap-2 rounded-[24px] bg-[#1363a6] hover:bg-[#1e40af] p-4 text-center text-[16px] font-extrabold text-white shadow-[0_0_30px_rgba(19,99,166,0.3)] transition-all hover:scale-[1.01] disabled:opacity-50 disabled:cursor-wait"
			onclick={handleDownloadPdf}
		>
			<svg class="w-5 h-5 {isGeneratingPdf ? 'animate-bounce' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
			</svg>
			{isGeneratingPdf ? 'Menyiapkan File PDF...' : 'Download PDF'}
		</button>
	</div>
</div>
