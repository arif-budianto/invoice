<script lang="ts">
	import { slide } from 'svelte/transition';
	import chevronDownIcon from '$lib/assets/chevron-down-icon.svg';

	type Option = { value: string; label: string };
	
	let { value = $bindable(), options } = $props<{
		value: string;
		options: Option[];
	}>();

	let isOpen = $state(false);

	function toggle() {
		isOpen = !isOpen;
	}

	function selectOption(val: string) {
		value = val;
		isOpen = false;
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
</script>

<div class="relative w-full" use:clickOutside>
	<button
		type="button"
		class="field w-full flex items-center justify-between bg-slate-900/50 hover:bg-slate-800/50 transition-colors text-left"
		onclick={toggle}
	>
		<span>{options.find((o: Option) => o.value === value)?.label || 'Pilih...'}</span>
		<img
			src={chevronDownIcon}
			alt=""
			class="w-4 h-4 opacity-50 transition-transform duration-200 {isOpen ? 'rotate-180' : ''}"
		/>
	</button>

	{#if isOpen}
		<div
			transition:slide={{ duration: 150 }}
			class="absolute z-50 w-full mt-2 rounded-[16px] border border-white/10 bg-[#0f172a] shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden"
		>
			<div class="max-h-60 overflow-y-auto p-1.5">
				{#each options as option (option.value)}
					<button
						type="button"
						class="w-full text-left px-3 py-2.5 text-sm rounded-xl transition-colors {value === option.value ? 'bg-cyan-500/10 text-cyan-400 font-semibold' : 'text-slate-300 hover:bg-white/5'}"
						onclick={() => selectOption(option.value)}
					>
						{option.label}
					</button>
				{/each}
			</div>
		</div>
	{/if}
</div>
