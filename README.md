# Invoice Builder

> Aplikasi web untuk membuat invoice profesional dengan pratinjau langsung, cetak, dan ekspor PDF melalui browser.

![SvelteKit](https://img.shields.io/badge/SvelteKit-2-FF3E00?logo=svelte&logoColor=white)
![Svelte](https://img.shields.io/badge/Svelte-5-FF3E00?logo=svelte&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-6-3178C6?logo=typescript&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## Daftar Isi

- [Ringkasan](#ringkasan)
- [Fitur Utama](#fitur-utama)
- [Tech Stack](#tech-stack)
- [Prasyarat](#prasyarat)
- [Instalasi](#instalasi)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Scripts](#scripts)
- [Struktur Proyek](#struktur-proyek)
- [Cara Pakai](#cara-pakai)
- [Ekspor PDF](#ekspor-pdf)
- [Cetak (Print)](#cetak-print)
- [Deployment](#deployment)
- [Lisensi](#lisensi)
- [Kontak](#kontak)

---

## Ringkasan

**Invoice Builder** adalah aplikasi web satu halaman untuk menyusun invoice secara cepat dan rapi. Seluruh proses berjalan sepenuhnya di sisi klien — tanpa backend, tanpa database. Pengguna mengisi data bisnis, data klien, dan item tagihan, lalu melihat hasilnya secara langsung pada panel pratinjau.

Panel pratinjau memisahkan dua konteks tampilan:

- **Workspace** — antarmuka gelap yang ringkas dan nyaman untuk proses input.
- **Dokumen invoice** — permukaan terang berformat A4 yang siap dicetak dan dibagikan.

Draft yang sedang dikerjakan tersimpan otomatis di `localStorage`, sehingga pekerjaan tidak hilang saat halaman di-reload.

---

## Fitur Utama

- **Pratinjau langsung** — dokumen invoice diperbarui real-time mengikuti perubahan form.
- **Data pengirim & klien** — mencakup nama, email, telepon, dan alamat.
- **Metode pembayaran** — nama bank, nomor rekening, dan atas nama.
- **Item tagihan dinamis** — tambah/hapus baris dengan deskripsi, kuantitas, dan harga.
- **Perhitungan otomatis** — subtotal, pajak (rate dapat diubah), dan total.
- **Multi-mata uang** — IDR, USD, dan SGD dengan format angka sesuai locale `id-ID`.
- **Nomor invoice & tanggal** — nomor invoice, tanggal terbit, dan jatuh tempo.
- **Pemilih tanggal kustom** — komponen date picker internal tanpa dependensi eksternal.
- **Catatan invoice** — teks bebas yang tampil di bagian bawah dokumen.
- **Ekspor PDF** — unduh invoice sebagai PDF A4 melalui `jsPDF` + `html-to-image`.
- **Cetak native** — dukungan `@media print` A4 portrait dengan warna akurat.
- **Paginasi otomatis** — item yang panjang dipisah ke beberapa halaman secara otomatis.
- **Draft tersimpan** — data form, item, dan pajak disimpan otomatis di browser.

---

## Tech Stack

| Kategori        | Teknologi                     |
| --------------- | ----------------------------- |
| Framework       | SvelteKit 2 (Svelte 5, runes) |
| Bahasa          | TypeScript                    |
| Styling         | Tailwind CSS 4                |
| Build Tool      | Vite 8                        |
| Ekspor PDF      | jsPDF + html-to-image         |
| Adapter         | `@sveltejs/adapter-node`      |
| Runtime         | Node.js 22+                   |
| Package Manager | pnpm                          |

---

## Prasyarat

- **Node.js** 22 atau lebih baru
- **pnpm** (disarankan mengaktifkan lewat `corepack enable`)

---

## Instalasi

Clone repositori lalu pasang dependensi:

```bash
git clone https://github.com/arif-budianto/invoice.git
cd invoice
pnpm install
```

---

## Menjalankan Aplikasi

Jalankan server pengembangan:

```bash
pnpm dev
```

Buka URL lokal yang ditampilkan Vite di terminal (default `http://localhost:5173`).

Untuk pratinjau hasil build produksi:

```bash
pnpm build
pnpm preview
```

---

## Scripts

| Script             | Deskripsi                                |
| ------------------ | ---------------------------------------- |
| `pnpm dev`         | Menjalankan server pengembangan Vite     |
| `pnpm build`       | Build aplikasi untuk produksi            |
| `pnpm preview`     | Pratinjau hasil build produksi           |
| `pnpm check`       | SvelteKit sync + pemeriksaan tipe Svelte |
| `pnpm check:watch` | Pemeriksaan tipe dalam mode watch        |
| `pnpm lint`        | Jalankan Prettier check dan ESLint       |
| `pnpm format`      | Format proyek dengan Prettier            |

---

## Struktur Proyek

```text
invoice/
├── src/
│   ├── routes/
│   │   ├── +page.svelte            # Halaman utama: state, perhitungan, penyimpanan draft
│   │   ├── +layout.svelte          # Layout aplikasi & favicon
│   │   └── layout.css              # Tailwind global, utilitas, dan style print
│   ├── lib/
│   │   ├── assets/                 # Aset SVG (favicon, ikon kalender, chevron)
│   │   ├── components/
│   │   │   ├── invoice/
│   │   │   │   ├── InvoiceForm.svelte     # Form input invoice (desktop & mobile)
│   │   │   │   └── InvoicePreview.svelte  # Dokumen invoice, paginasi, ekspor PDF
│   │   │   └── ui/
│   │   │       ├── DatePicker.svelte      # Pemilih tanggal kustom
│   │   │       └── Select.svelte          # Dropdown kustom
│   │   └── types/invoice.ts        # Tipe data InvoiceFormData & InvoiceItem
│   └── app.html                    # Template HTML SvelteKit
├── static/                         # Aset statis (robots.txt)
├── Dockerfile                      # Build multi-stage (Node 22 + pnpm)
├── svelte.config.js                # Konfigurasi SvelteKit (adapter-node)
├── vite.config.ts                  # Konfigurasi Vite + Tailwind
└── package.json
```

---

## Cara Pakai

1. Isi **Nomor Invoice**, **Mata Uang**, **Tanggal Terbit**, dan **Jatuh Tempo**.
2. Lengkapi **Metode Pembayaran**: nama bank, nomor rekening, atas nama.
3. Isi **Data Pengirim** dan **Data Klien**.
4. Tambahkan **item tagihan** (deskripsi, qty, harga) sesuai kebutuhan.
5. Atur **Pajak (%)** pada panel ringkasan nilai tagihan.
6. Tulis **Catatan** bila perlu.
7. Periksa hasil pada panel pratinjau, lalu **Download PDF**.

Pada layar kecil, tombol **Lihat Hasil Preview** berpindah antara form dan dokumen.

---

## Ekspor PDF

Tombol **Download PDF** membangun file langsung di browser:

- Setiap halaman dirender menjadi gambar PNG (`html-to-image`, rasio piksel 2×).
- Gambar ditempatkan ke halaman **A4 portrait** (`jsPDF`).
- Nama file mengikuti `Nomor Invoice - Nama Klien.pdf` bila terisi.

Tidak ada proses server dan tidak ada upload data — seluruh ekspor berjalan lokal di perangkat pengguna.

---

## Cetak (Print)

Aplikasi menyediakan gaya khusus `@media print`:

- Format **A4 portrait** dengan margin yang telah diatur.
- Warna dicetak akurat (`print-color-adjust: exact`).
- Hanya dokumen invoice yang tercetak; antarmuka form disembunyikan.

Gunakan perintah cetak browser dan pilih **Save as PDF** sebagai alternatif ekspor.

---

## Deployment

### Build produksi (Node)

```bash
pnpm install --frozen-lockfile
pnpm build
node build
```

Server berjalan pada port `3000` (dapat diubah lewat variabel lingkungan `PORT`).

### Docker

Repositori menyertakan `Dockerfile` multi-stage berbasis `node:22-slim`:

```bash
docker build -t invoice-builder .
docker run -p 3000:3000 invoice-builder
```

---

## Lisensi

Proyek ini **proprietary** — hak cipta dilindungi. Seluruh hak dipegang oleh pemiliknya.

Penggunaan komersial, distribusi, republikasi, atau klaim kepemilikan atas kode ini **tidak diizinkan** tanpa izin tertulis dari pemilik hak cipta. Lihat [LICENSE](./LICENSE) untuk ketentuan lengkap.

---

## Kontak

|             |                                  |
| ----------- | -------------------------------- |
| **Pemilik** | Arif Budianto                    |
| **Email**   | tigers@fedoraweb.site            |
| **Website** | https://tigers.my.id             |
| **GitHub**  | https://github.com/arif-budianto |

---

Copyright (c) 2026 Arif Budianto. All rights reserved.
