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

	let isGeneratingPdf = $state(false);
	let downloadError = $state<string | null>(null);
	let previewWrapperWidth = $state(0);
	
	let scale = $derived(previewWrapperWidth > 0 && previewWrapperWidth < 820 ? previewWrapperWidth / 820 : 1);
	const invoicePages = $derived.by(() => {
		const pages = [];
		let remaining = [...items];
		let pageIndex = 0;
		let hasFooter = false;

		if (remaining.length === 0) {
			return [{ pageItems: [], isFirst: true, isLast: true, pageNumber: 1 }];
		}

		while (!hasFooter) {
			let isFirst = pageIndex === 0;
			let maxWithFooter = isFirst ? 7 : 10;
			let maxNoFooter = isFirst ? 12 : 15;

			if (remaining.length <= maxWithFooter) {
				pages.push({ 
					pageItems: remaining.splice(0, remaining.length), 
					isFirst, 
					isLast: true,
					pageNumber: pageIndex + 1
				});
				hasFooter = true;
			} else {
				pages.push({ 
					pageItems: remaining.splice(0, maxNoFooter), 
					isFirst, 
					isLast: false,
					pageNumber: pageIndex + 1
				});
			}
			pageIndex++;
		}
		return pages;
	});

	let totalHeight = $derived(invoicePages.length * 1123 + Math.max(0, invoicePages.length - 1) * 32);

	async function handleDownloadPdf() {
		if (typeof window === 'undefined') return;
		
		isGeneratingPdf = true;
		downloadError = null;

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

	<div class="w-full max-w-[820px] mx-auto flex justify-center" bind:clientWidth={previewWrapperWidth}>
		<div 
			id="invoice-pdf-container" 
			class="flex flex-col gap-8 w-[794px] items-center"
			style="transform: scale({scale}); transform-origin: top center; margin-bottom: {totalHeight * (scale - 1)}px;"
		>
			{#each invoicePages as page (page.pageNumber)}
				<div id="printable-page-{page.pageNumber}" class="bg-white p-14 text-slate-800 relative print:m-0 print:shadow-none print:overflow-visible shadow-2xl border border-slate-200 w-[794px] h-[1123px] shrink-0 flex flex-col font-sans box-border overflow-hidden print:break-after-page">
					
				{#if page.isFirst}
					<div class="mb-12 shrink-0">
						<h1 class="text-5xl font-black tracking-tight text-slate-900 mb-4 uppercase">INVOICE</h1>
						<div class="text-sm text-slate-700 leading-snug space-y-0.5">
							{#if form.fromName}<p>{form.fromName}</p>{/if}
							{#if form.fromAddress}<p>{form.fromAddress}</p>{/if}
							{#if form.fromPhone}<p>{form.fromPhone}</p>{/if}
							{#if form.fromEmail}<p>{form.fromEmail}</p>{/if}
						</div>
					</div>

					<div class="flex flex-row justify-between items-start gap-0 mb-6 shrink-0">
						<div class="w-1/2">
							<p class="text-[11px] font-bold tracking-widest text-slate-500 uppercase mb-2">BILL TO</p>
							<div class="text-sm text-slate-800 leading-snug space-y-0.5">
								{#if form.clientName}<p>{form.clientName}</p>{/if}
								{#if form.clientAddress}<p>{form.clientAddress}</p>{/if}
								{#if form.clientPhone}<p>{form.clientPhone}</p>{/if}
								{#if form.clientEmail}<p>{form.clientEmail}</p>{/if}
							</div>
						</div>

						<div class="w-1/2">
							<table class="text-sm text-right ml-auto">
								<tbody>
									<tr>
										<td class="font-bold text-slate-900 pr-3 pb-1 whitespace-nowrap">Invoice #:</td>
										<td class="pb-1">{form.invoiceNumber || '-'}</td>
									</tr>
									<tr>
										<td class="font-bold text-slate-900 pr-3 pb-1 whitespace-nowrap">Date:</td>
										<td class="pb-1">{formatDate(form.issueDate)}</td>
									</tr>
									<tr>
										<td class="font-bold text-slate-900 pr-3 pb-1 whitespace-nowrap">Due Date:</td>
										<td class="pb-1">{formatDate(form.dueDate)}</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				{/if}

				{#if !page.isFirst}
					<div class="flex justify-between items-end mb-6 pt-4 shrink-0">
						<h2 class="text-2xl font-black text-slate-900 uppercase">INVOICE</h2>
						<div class="text-right text-sm text-slate-700">
							<p class="font-bold">{form.invoiceNumber || '-'}</p>
							<p>{form.clientName || '-'}</p>
						</div>
					</div>
				{/if}

				<div class="h-[2px] bg-slate-800 mb-6 w-full shrink-0" style="-webkit-print-color-adjust: exact;"></div>

				<div class="mb-8 flex-grow">
					<table class="w-full text-left border-collapse border border-slate-400">
						<thead class="bg-slate-100 border-y border-slate-400" style="-webkit-print-color-adjust: exact;">
							<tr>
								<th class="py-3 px-4 text-[11px] font-bold text-slate-800 uppercase tracking-widest w-[50%]">ITEM</th>
								<th class="py-3 px-4 text-[11px] font-bold text-slate-800 uppercase tracking-widest text-center w-[15%]">QTY</th>
								<th class="py-3 px-4 text-[11px] font-bold text-slate-800 uppercase tracking-widest text-center w-[15%]">PRICE</th>
								<th class="py-3 px-4 text-[11px] font-bold text-slate-800 uppercase tracking-widest text-right w-[20%]">TOTAL</th>
							</tr>
						</thead>
						<tbody class="divide-y divide-slate-300 border-b border-slate-400">
							{#each page.pageItems as item (item.id)}
								<tr>
									<td class="py-4 px-4 text-sm text-slate-800 pr-8 font-medium">{item.description || '-'}</td>
									<td class="py-4 px-4 text-sm text-slate-800 text-center">{item.quantity}</td>
									<td class="py-4 px-4 text-sm text-slate-800 text-center">{formatCurrency(item.unitPrice)}</td>
									<td class="py-4 px-4 text-sm text-slate-800 text-right font-semibold">{formatCurrency(item.quantity * item.unitPrice)}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>

				{#if page.isLast}
					<div class="flex justify-end mb-12 shrink-0">
						<div class="w-[45%]">
							<div class="space-y-2 text-sm text-slate-600 px-4">
								<div class="flex justify-between">
									<span>Subtotal:</span>
									<span class="font-bold text-slate-900">{formatCurrency(subtotal)}</span>
								</div>
								<div class="flex justify-between">
									<span>Pajak ({taxRate}%):</span>
									<span class="text-slate-900">{formatCurrency(taxAmount)}</span>
								</div>
								<div class="h-[2px] bg-slate-800 mt-3 mb-2" style="-webkit-print-color-adjust: exact;"></div>
								<div class="flex justify-between items-center py-1">
									<span class="text-base font-bold text-slate-900">Total:</span>
									<span class="text-base font-bold text-slate-900">{formatCurrency(total)}</span>
								</div>
								<div class="h-[4px] bg-slate-800" style="-webkit-print-color-adjust: exact;"></div>
							</div>
						</div>
					</div>

					<div class="mt-auto pt-8 shrink-0">
						<p class="text-[11px] font-bold tracking-widest text-slate-500 uppercase mb-2">NOTES</p>
						<p class="text-sm text-slate-600 leading-relaxed whitespace-pre-wrap">{form.notes || 'Terima kasih atas kerja sama Anda.'}</p>
					</div>
				{/if}

				{#if invoicePages.length > 1}
					<div class="absolute bottom-6 left-0 w-full text-center text-[10px] text-slate-400 font-medium uppercase tracking-widest print:hidden">
						Halaman {page.pageNumber} dari {invoicePages.length}
					</div>
				{/if}
			</div>
		{/each}
	</div>
	</div>

	<div class="mt-4 flex w-full max-w-[794px] flex-col print:hidden px-4 sm:px-0">
		<button
			disabled={isGeneratingPdf}
			class="w-full cursor-pointer flex items-center justify-center gap-2 rounded-[24px] bg-cyan-500 hover:bg-cyan-400 p-4 text-center text-[16px] font-extrabold text-slate-900 shadow-[0_0_30px_rgba(34,211,238,0.3)] transition-all hover:scale-[1.01] disabled:opacity-50 disabled:cursor-wait"
			onclick={handleDownloadPdf}
		>
			<svg class="w-5 h-5 {isGeneratingPdf ? 'animate-bounce' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
			</svg>
			{isGeneratingPdf ? 'Menyiapkan File PDF...' : 'Download PDF'}
		</button>
	</div>
</div>
