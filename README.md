# Invoice Builder

A modern web-based invoice builder with live invoice preview, print or save as PDF support through the browser, dark mode, and a mobile-friendly interface.

## Fitur Utama

- Form invoice interaktif untuk data bisnis, klien, tanggal, mata uang, dan catatan
- Preview invoice langsung saat data diubah
- Perhitungan subtotal, pajak, dan total secara otomatis
- Daftar item invoice dinamis dengan tambah dan hapus item
- Tampilan dark mode sebagai default dengan layout responsif untuk mobile dan desktop
- Siap dicetak atau disimpan sebagai PDF menggunakan fitur print browser

## Tech Stack

- SvelteKit 2
- Svelte 5
- TypeScript
- Tailwind CSS 4
- Drizzle ORM
- PostgreSQL
- Vite

## Instalasi dan Menjalankan Lokal

### Prasyarat

- Node.js
- pnpm
- PostgreSQL

### Langkah Setup

1. Clone repository ini.
2. Install dependency:

   ```bash
   pnpm install
   ```

3. Salin file environment:

   ```bash
   cp .env.example .env
   ```

4. Isi `DATABASE_URL` di `.env` sesuai koneksi PostgreSQL Anda.
5. Jalankan development server:

   ```bash
   pnpm dev
   ```

6. Buka aplikasi di browser sesuai URL yang ditampilkan terminal.

## Scripts

| Script             | Keterangan                                                    |
| ------------------ | ------------------------------------------------------------- |
| `pnpm dev`         | Menjalankan development server                                |
| `pnpm build`       | Membuat build production                                      |
| `pnpm preview`     | Menjalankan preview build production                          |
| `pnpm check`       | Menjalankan sinkronisasi SvelteKit dan pemeriksaan type/check |
| `pnpm check:watch` | Menjalankan pemeriksaan type/check dalam mode watch           |
| `pnpm lint`        | Menjalankan Prettier check dan ESLint                         |
| `pnpm format`      | Merapikan format file dengan Prettier                         |
| `pnpm db:push`     | Mendorong schema database ke database target                  |
| `pnpm db:generate` | Membuat file migration Drizzle                                |
| `pnpm db:migrate`  | Menjalankan migration database                                |
| `pnpm db:studio`   | Membuka Drizzle Studio                                        |

## Struktur File Penting

```text
src/
├── routes/
│   ├── +page.svelte                    # Halaman utama invoice builder
│   ├── +layout.svelte                  # Layout aplikasi
│   └── layout.css                      # Global styling
├── lib/
│   ├── components/invoice/
│   │   ├── InvoiceForm.svelte          # Form input invoice
│   │   └── InvoicePreview.svelte       # Preview invoice
│   ├── server/db/
│   │   ├── index.ts                    # Koneksi database
│   │   └── schema.ts                   # Schema database Drizzle
│   └── types/invoice.ts                # Type data invoice
├── app.html                            # Template HTML utama
├── drizzle.config.ts                   # Konfigurasi Drizzle
└── svelte.config.js                    # Konfigurasi SvelteKit
```

## Catatan

Fitur simpan PDF menggunakan dialog print browser (`Print` / `Save as PDF`) dari preview invoice yang ditampilkan aplikasi.
