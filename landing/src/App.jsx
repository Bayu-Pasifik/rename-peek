import React from 'react';
import { LiquidGlass } from 'quick-liquid/react';

const REPO = 'https://github.com/Bayu-Pasifik/rename-peek';
const REL = `${REPO}/releases/latest`;
const SETUP = `${REPO}/releases/download/v1.1.0/RenamePeek-Setup-1.1.0.exe`;
const ZIP = `${REPO}/releases/download/v1.1.0/RenamePeek-1.1.0-windows-portable.zip`;

const glass = (extra = {}) => ({
  material: 'regular',
  borderRadius: 24,
  dynamicLighting: true,
  chromaticAberration: 0.2,
  ...extra,
});

const features = [
  ['Kelompok otomatis', 'File bernama sama seperti dokumen, dokumen (1), dokumen (2) dikelompokkan dan diurutkan secara numerik.'],
  ['Preview besar', 'PDF, gambar, teks, serta Word, Excel, dan PowerPoint (dikonversi lewat Microsoft Office yang terpasang).'],
  ['Rename aman', 'Karakter ilegal dibuang, nama bentrok diberi suffix, tidak pernah menimpa file, tidak ada operasi hapus.'],
  ['Undo berlapis', 'Salah ketik? Ctrl+Z. Riwayat tetap ada setelah aplikasi ditutup.'],
  ['Keyboard dulu', 'Seluruh alur jalan tanpa mouse. Fokus selalu kembali ke kolom nama.'],
  ['Terang dan gelap', 'Mengikuti tema Windows, bisa dipaksa di pengaturan.'],
];

const steps = [
  ['Pilih folder', 'Klik atau seret folder unduhan ke jendela.'],
  ['Lihat', 'Preview file muncul langsung, tanpa membuka aplikasi lain.'],
  ['Ketik lalu Enter', 'Nama baru tersimpan dan aplikasi lompat ke file berikutnya.'],
];

function Mock() {
  return (
    <LiquidGlass config={glass({ material: 'thin', borderRadius: 20 })} animateIn={200} className="mock-wrap">
      <div className="mock">
        <div className="mock-bar"><i /><i /><i /><span>Rename Peek</span></div>
        <div className="mock-body">
          <ul>
            <li className="on">dokumen.pdf</li>
            <li>dokumen (1).pdf</li>
            <li>dokumen (2).xlsx</li>
            <li>dokumen (3).docx</li>
          </ul>
          <div className="mock-main">
            <div className="mock-input">Laporan Keuangan Q3<b>.pdf</b></div>
            <div className="mock-page">
              <p /><p /><p className="s" /><p /><p className="s" />
            </div>
          </div>
        </div>
      </div>
    </LiquidGlass>
  );
}

export default function App() {
  return (
    <>
      <div className="bg" aria-hidden="true"><span className="b1" /><span className="b2" /><span className="b3" /></div>

      <header className="nav">
        <LiquidGlass config={glass({ borderRadius: 999 })} animateIn={0}>
          <nav>
            <a className="brand" href="#top"><img src="/rename-peek/icon.png" alt="" width="22" height="22" />Rename Peek</a>
            <a href="#cara">Cara pakai</a>
            <a href="#fitur">Fitur</a>
            <a href="#unduh">Unduh</a>
            <a href={REPO} target="_blank" rel="noreferrer">GitHub</a>
          </nav>
        </LiquidGlass>
      </header>

      <main id="top">
        <section className="hero">
          <p className="eyebrow">Aplikasi Windows · gratis · open source</p>
          <h1>Lihat dulu,<br />baru beri nama.</h1>
          <p className="lead">
            Puluhan file bernama <code>dokumen (1)</code>, <code>dokumen (2)</code> hasil unduhan?
            Rename Peek menampilkan isinya satu per satu. Ketik nama, tekan Enter, selesai.
          </p>
          <div className="cta">
            <LiquidGlass config={glass({ material: 'clear', borderRadius: 18 })} liquidPress={{ scale: 0.94, squish: 0.03 }}>
              <a className="btn primary" href={SETUP}>Unduh untuk Windows</a>
            </LiquidGlass>
            <LiquidGlass config={glass({ material: 'thin', borderRadius: 18 })} liquidPress={{ scale: 0.94, squish: 0.03 }}>
              <a className="btn" href={REPO} target="_blank" rel="noreferrer">Lihat di GitHub</a>
            </LiquidGlass>
          </div>
          <p className="note">v1.1.0 · Windows 10/11 · installer 14 MB</p>
          <Mock />
        </section>

        <section id="cara" className="section">
          <h2>Tiga langkah, tanpa pindah jendela</h2>
          <div className="grid3">
            {steps.map(([t, d], i) => (
              <LiquidGlass key={t} config={glass()} animateIn={i * 80}>
                <div className="card"><span className="num">{i + 1}</span><h3>{t}</h3><p>{d}</p></div>
              </LiquidGlass>
            ))}
          </div>
        </section>

        <section id="fitur" className="section">
          <h2>Dibuat untuk sesi panjang</h2>
          <div className="grid3">
            {features.map(([t, d], i) => (
              <LiquidGlass key={t} config={glass({ material: 'thin' })} animateIn={i * 60}>
                <div className="card"><h3>{t}</h3><p>{d}</p></div>
              </LiquidGlass>
            ))}
          </div>
        </section>

        <section id="unduh" className="section">
          <LiquidGlass config={glass({ material: 'thick', borderRadius: 32 })}>
            <div className="download">
              <h2>Siap merapikan folder unduhan?</h2>
              <p>Pilih installer atau versi portabel yang tinggal diekstrak. Keduanya tanpa akun dan tanpa iklan.</p>
              <div className="cta">
                <a className="btn primary" href={SETUP}>Installer (.exe)</a>
                <a className="btn" href={ZIP}>Portabel (.zip)</a>
                <a className="btn" href={REL} target="_blank" rel="noreferrer">Semua rilis</a>
              </div>
              <p className="note">Installer belum ditandatangani, jadi Windows SmartScreen bisa menampilkan peringatan "publisher tidak dikenal". Pilih "More info" lalu "Run anyway".</p>
            </div>
          </LiquidGlass>
        </section>
      </main>

      <footer>Rename Peek · dibuat dengan Flutter · halaman ini memakai <a href="https://github.com/amarnath3003/quickLiquid" target="_blank" rel="noreferrer">QuickLiquid</a></footer>
    </>
  );
}
