## Description

This issue tracks the implementation of a new **Percentage-Based Discount** feature and the refinement of the **Payment Method** section within the Invoice Builder to align with standard commercial accounting practices and the "Quiet Luxury" design system.

### Objectives
1. **Discount Implementation**: Introduce a dynamic discount field calculated as a percentage (%) of the subtotal.
2. **Accounting Accuracy**: Ensure the tax calculation (PPN) is strictly applied to the *Taxable Amount* (Subtotal After Discount) rather than the gross subtotal.
3. **UI/UX Refinement**: 
   - Integrate the "Diskon (%)" input seamlessly alongside the "Pajak (%)" input within the *Ringkasan nilai tagihan* section.
   - Implement auto-formatting for the "No. Rekening" field to group digits into blocks of 4 (e.g., `1234 5678 9101`) via an `onblur` event.
   - Ensure the "Metode Pembayaran" text sizes, margins, and gaps precisely match the "Ditagihkan Kepada" layout in the PDF export for a balanced, symmetrical presentation.

## Tasks
- [x] Refactor `InvoicePreview.svelte` to fix layout misalignment and typography scaling between the "Invoice To" and "Payment Method" grids.
- [x] Add auto-formatting logic (`onblur`) to the Bank Account input in `InvoiceForm.svelte` to enhance UX and readability.
- [x] Expand `InvoiceFormData` type definition in `src/lib/types/invoice.ts` to include `discount: number`.
- [x] Overhaul total calculation logic in `+page.svelte` to strictly follow commercial standards (`Total = (Subtotal - Discount) + Tax`).
- [x] Conditionally render the "Diskon" row in the generated PDF summary table, styled with distinct typography (`text-rose-600`) to indicate a deduction.

## Expected Behavior
- When a user enters a discount percentage (e.g., 10%), the subtotal decreases accordingly *before* tax is calculated.
- The UI maintains a clean, side-by-side presentation for Tax and Discount inputs without redundant component nesting.
- Exported PDFs display flawless symmetrical alignment between billing and payment details, meeting enterprise visual standards.
