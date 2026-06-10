<script lang="ts">
	import { slide } from 'svelte/transition';
	import calendarIcon from '$lib/assets/calendar-icon.svg';

	let { value = $bindable(), align = 'center' } = $props<{ value: string; align?: 'left' | 'center' | 'right' }>();

	let isOpen = $state(false);
	
	let initialDate = value ? new Date(value) : new Date();
	let viewMonth = $state(initialDate.getMonth());
	let viewYear = $state(initialDate.getFullYear());

	const monthNames = [
		'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
		'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
	];
	const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

	function toggle() {
		if (!isOpen) {
			const d = value ? new Date(value) : new Date();
			viewMonth = d.getMonth();
			viewYear = d.getFullYear();
		}
		isOpen = !isOpen;
	}

	function selectDate(day: number) {
		const d = new Date(viewYear, viewMonth, day);
		const yyyy = d.getFullYear();
		const mm = String(d.getMonth() + 1).padStart(2, '0');
		const dd = String(d.getDate()).padStart(2, '0');
		value = `${yyyy}-${mm}-${dd}`;
		isOpen = false;
	}

	function prevMonth() {
		if (viewMonth === 0) {
			viewMonth = 11;
			viewYear--;
		} else {
			viewMonth--;
		}
	}

	function nextMonth() {
		if (viewMonth === 11) {
			viewMonth = 0;
			viewYear++;
		} else {
			viewMonth++;
		}
	}

	function clickOutside(node: HTMLElement) {
		const handleClick = (event: MouseEvent) => {
			if (!node.contains(event.target as Node)) {
				isOpen = false;
			}
		};
		document.addEventListener('click', handleClick, true);
		return {
			destroy() {
				document.removeEventListener('click', handleClick, true);
			}
		};
	}

	function getDaysInMonth(year: number, month: number) {
		return new Date(year, month + 1, 0).getDate();
	}

	function getFirstDayOfMonth(year: number, month: number) {
		return new Date(year, month, 1).getDay();
	}

	let daysArray = $derived.by(() => {
		const daysInMonth = getDaysInMonth(viewYear, viewMonth);
		const firstDay = getFirstDayOfMonth(viewYear, viewMonth);
		
		const days = [];
		for (let i = 0; i < firstDay; i++) {
			days.push(null);
		}
		for (let i = 1; i <= daysInMonth; i++) {
			days.push(i);
		}
		return days;
	});

	let displayValue = $derived.by(() => {
		if (!value) return '';
		const d = new Date(value);
		if (isNaN(d.getTime())) return value;
		return `${d.getDate()} ${monthNames[d.getMonth()]} ${d.getFullYear()}`;
	});
</script>

<div class="relative w-full" use:clickOutside>
	<button
		type="button"
		class="field w-full flex items-center justify-between bg-slate-900/50 hover:bg-slate-800/50 transition-colors text-left"
		onclick={toggle}
	>
		<span class={displayValue ? 'text-white' : 'text-slate-500'}>
			{displayValue || 'Pilih Tanggal'}
		</span>
		<img
			src={calendarIcon}
			alt=""
			class="w-4 h-4 opacity-50"
		/>
	</button>

	{#if isOpen}
		<div
			transition:slide={{ duration: 150 }}
			class="absolute z-50 top-[calc(100%+8px)] w-[280px] rounded-[20px] border border-white/10 bg-[#0f172a] shadow-[0_30px_60px_rgba(0,0,0,0.6)] p-5
				{align === 'center' ? 'left-1/2 -translate-x-1/2' : align === 'right' ? 'right-0' : 'left-0'}"
		>
			<div class="flex justify-between items-center mb-5">
				<button type="button" aria-label="Bulan sebelumnya" class="p-1 text-slate-400 hover:text-white transition-colors hover:bg-white/10 rounded-full" onclick={prevMonth}>
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
				</button>
				<span class="text-sm font-semibold text-white tracking-wide">{monthNames[viewMonth]} {viewYear}</span>
				<button type="button" aria-label="Bulan berikutnya" class="p-1 text-slate-400 hover:text-white transition-colors hover:bg-white/10 rounded-full" onclick={nextMonth}>
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path></svg>
				</button>
			</div>

			<div class="grid grid-cols-7 gap-1 text-center mb-3">
				{#each dayNames as day (day)}
					<div class="text-[10px] font-bold text-slate-500 uppercase tracking-wider">{day}</div>
				{/each}
			</div>

			<div class="grid grid-cols-7 gap-y-2 gap-x-1">
				{#each daysArray as day, i (i)}
					{#if day === null}
						<div></div>
					{:else}
						{@const isSelected = value === `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`}
						{@const isToday = new Date().toDateString() === new Date(viewYear, viewMonth, day).toDateString()}
						<button
							type="button"
							class="w-8 h-8 mx-auto flex items-center justify-center text-[13px] rounded-full transition-all
								{isSelected ? 'bg-cyan-500 text-white shadow-[0_0_15px_rgba(34,211,238,0.4)] font-bold' : 
								 isToday ? 'text-cyan-400 border border-cyan-500/30 bg-cyan-500/10' : 
								 'text-slate-300 hover:bg-white/10'}"
							onclick={() => selectDate(day)}
						>
							{day}
						</button>
					{/if}
				{/each}
			</div>
		</div>
	{/if}
</div>
