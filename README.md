# Invoice Builder

Invoice Builder is a focused web app for creating clean, professional invoices with a live preview. It is designed for simple operational use: fill in the business, client, date, currency, and line-item details, then print or save the final invoice as a PDF through the browser's native print flow.

The app keeps the editing experience dark, compact, and easy to scan, while the invoice document itself is rendered on a light surface so it remains suitable for printing and sharing.

## Highlights

- Live invoice preview that updates as the form changes
- Business and client detail fields for practical invoice use cases
- Dynamic invoice items with quantity, unit price, subtotal, tax, and total calculation
- Currency selection for IDR, USD, and SGD
- Native browser print flow for printing or saving the invoice as PDF
- Mobile-friendly builder layout with a readable preview structure
- Dark-mode workspace with a clean printable invoice document

## Tech Stack

- SvelteKit 2
- Svelte 5
- TypeScript
- Tailwind CSS 4
- Vite

## Getting Started

### Prerequisites

- Node.js
- pnpm

### Installation

Clone the repository and install dependencies:

```bash
pnpm install
```

Start the development server:

```bash
pnpm dev
```

Open the local URL printed by Vite in the terminal.

## Available Scripts

| Script             | Description                                 |
| ------------------ | ------------------------------------------- |
| `pnpm dev`         | Start the Vite development server           |
| `pnpm build`       | Build the app for production                |
| `pnpm preview`     | Preview the production build                |
| `pnpm check`       | Run SvelteKit sync and Svelte type checking |
| `pnpm check:watch` | Run Svelte type checking in watch mode      |
| `pnpm lint`        | Run Prettier check and ESLint               |
| `pnpm format`      | Format the project with Prettier            |

## Project Structure

```text
src/
├── routes/
│   ├── +page.svelte              # Main invoice builder page
│   ├── +layout.svelte            # Application layout and favicon setup
│   └── layout.css                # Global Tailwind and print styles
├── lib/
│   ├── assets/                   # SVG assets used by the UI
│   ├── components/invoice/
│   │   ├── InvoiceForm.svelte    # Invoice input form
│   │   └── InvoicePreview.svelte # Printable invoice preview
│   └── types/invoice.ts          # Invoice data types
└── app.html                      # SvelteKit HTML template
```

## PDF Export

The `Download PDF` action uses the browser's native print dialog. Choose **Save as PDF** as the destination to export the current invoice. This avoids canvas-based PDF rendering issues and keeps the output aligned with how modern browsers render print layouts.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
