import React from 'react';

const REPO = 'https://github.com/Bayu-Pasifik/rename-peek';
const REL = `${REPO}/releases/latest`;
const SETUP = `${REPO}/releases/download/v1.1.0/RenamePeek-Setup-1.1.0.exe`;
const ZIP = `${REPO}/releases/download/v1.1.0/RenamePeek-1.1.0-windows-portable.zip`;

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
    <figure className="mock" aria-hidden="true">
      <div className="mock-bar">Rename Peek — dokumen.pdf</div>
      <div className="mock-body">
        <ul>
          <li className="on">dokumen.pdf</li>
          <li>dokumen (1).pdf</li>
          <li>dokumen (2).xlsx</li>
          <li>dokumen (3).docx</li>
        </ul>
        <div>
          <div className="mock-input">Laporan Keuangan Q3<b>.pdf</b></div>
          <div className="mock-page"><p /><p /><p className="s" /><p /><p className="s" /></div>
        </div>
      </div>
      <figcaption>Gambar 1. Daftar file di kiri, kolom nama di atas preview.</figcaption>
    </figure>
  );
}

export default function App() {
  return (
    <div className="paper" id="top">
      <header className="masthead">
        <div className="meta">
          <span>Edisi v1.1.0</span>
          <span>Windows 10/11</span>
          <span>Gratis</span>
        </div>
        <h1 className="title">The Rename Peek</h1>
        <nav>
          <a href="#cara">Cara pakai</a>
          <a href="#fitur">Fitur</a>
          <a href="#unduh">Unduh</a>
          <a href={REPO} target="_blank" rel="noreferrer">Kode sumber</a>
        </nav>
      </header>

      <section className="front">
        <article className="lead-story">
          <p className="kicker">Aplikasi Windows · Open source</p>
          <h2 className="headline">Lihat dulu, baru beri nama</h2>
          <p className="deck">
            Puluhan file hasil unduhan bernama <i>dokumen (1)</i>, <i>dokumen (2)</i> tak perlu lagi dibuka satu per satu.
            Rename Peek menampilkan isinya. Ketik nama, tekan Enter, selesai.
          </p>
          <p className="cta">
            <a className="btn" href={SETUP}>Unduh untuk Windows</a>
            <a className="link" href={REPO} target="_blank" rel="noreferrer">Baca kode sumber →</a>
          </p>
        </article>
        <Mock />
      </section>

      <section id="cara" className="block">
        <h3 className="section">Cara pakai</h3>
        <div className="cols3">
          {steps.map(([t, d], i) => (
            <article key={t}>
              <span className="dropnum">{i + 1}</span>
              <h4>{t}</h4>
              <p>{d}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="fitur" className="block">
        <h3 className="section">Fitur</h3>
        <div className="cols3">
          {features.map(([t, d]) => (
            <article key={t}>
              <h4>{t}</h4>
              <p>{d}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="unduh" className="block notice">
        <h3 className="section">Unduh</h3>
        <h2 className="headline small">Siap merapikan folder unduhan?</h2>
        <p>Pilih installer atau versi portabel yang tinggal diekstrak. Keduanya tanpa akun dan tanpa iklan.</p>
        <p className="cta">
          <a className="btn" href={SETUP}>Installer (.exe)</a>
          <a className="btn alt" href={ZIP}>Portabel (.zip)</a>
          <a className="link" href={REL} target="_blank" rel="noreferrer">Semua rilis →</a>
        </p>
        <p className="fine">Catatan: installer belum ditandatangani, jadi Windows SmartScreen bisa menampilkan peringatan "publisher tidak dikenal". Pilih "More info" lalu "Run anyway".</p>
      </section>

      <footer>The Rename Peek · dibuat dengan Flutter · <a href={REPO} target="_blank" rel="noreferrer">GitHub</a></footer>
    </div>
  );
}
