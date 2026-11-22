import React from 'react';

const REPO = 'https://github.com/Bayu-Pasifik/rename-peek';
const REL = `${REPO}/releases/latest`;
const SETUP = `${REPO}/releases/download/v1.1.0/RenamePeek-Setup-1.1.0.exe`;
const ZIP = `${REPO}/releases/download/v1.1.0/RenamePeek-1.1.0-windows-portable.zip`;

const features = [
  ['Kelompok otomatis', 'File bernama sama seperti dokumen, dokumen (1), dokumen (2) dikelompokkan dan diurutkan secara numerik.', 'c1'],
  ['Preview besar', 'PDF, gambar, teks, serta Word, Excel, dan PowerPoint (dikonversi lewat Microsoft Office yang terpasang).', 'c2'],
  ['Rename aman', 'Karakter ilegal dibuang, nama bentrok diberi suffix, tidak pernah menimpa file, tidak ada operasi hapus.', 'c3'],
  ['Undo berlapis', 'Salah ketik? Ctrl+Z. Riwayat tetap ada setelah aplikasi ditutup.', 'c3'],
  ['Keyboard dulu', 'Seluruh alur jalan tanpa mouse. Fokus selalu kembali ke kolom nama.', 'c1'],
  ['Terang dan gelap', 'Mengikuti tema Windows, bisa dipaksa di pengaturan.', 'c2'],
];

const steps = [
  ['Pilih folder', 'Klik atau seret folder unduhan ke jendela.'],
  ['Lihat', 'Preview file muncul langsung, tanpa membuka aplikasi lain.'],
  ['Ketik lalu Enter', 'Nama baru tersimpan dan aplikasi lompat ke file berikutnya.'],
];

function Mock() {
  return (
    <div className="mock" aria-hidden="true">
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
          <div className="mock-page"><p /><p /><p className="s" /><p /><p className="s" /></div>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <>
      <header className="nav">
        <nav>
          <a className="brand" href="#top"><img src="/rename-peek/icon.png" alt="" width="24" height="24" />Rename Peek</a>
          <a href="#cara">Cara pakai</a>
          <a href="#fitur">Fitur</a>
          <a href="#unduh">Unduh</a>
          <a href={REPO} target="_blank" rel="noreferrer">GitHub</a>
        </nav>
      </header>

      <main id="top">
        <section className="hero">
          <div className="wrap hero-grid">
            <div>
              <p className="eyebrow">Aplikasi Windows · gratis · open source</p>
              <h1>Lihat dulu, baru beri nama.</h1>
              <p className="lead">
                Puluhan file bernama <code>dokumen (1)</code>, <code>dokumen (2)</code> hasil unduhan?
                Rename Peek menampilkan isinya satu per satu. Ketik nama, tekan Enter, selesai.
              </p>
              <div className="cta">
                <a className="btn primary" href={SETUP}>Unduh untuk Windows</a>
                <a className="btn" href={REPO} target="_blank" rel="noreferrer">Lihat di GitHub</a>
              </div>
              <p className="note">v1.1.0 · Windows 10/11 · installer 14 MB</p>
            </div>
            <Mock />
          </div>
        </section>

        <section id="cara" className="band ink">
          <div className="wrap">
            <h2>Tiga langkah, tanpa pindah jendela</h2>
            <div className="grid3">
              {steps.map(([t, d], i) => (
                <div className="tile" key={t}><span className="num">{i + 1}</span><h3>{t}</h3><p>{d}</p></div>
              ))}
            </div>
          </div>
        </section>

        <section id="fitur" className="band">
          <div className="wrap">
            <h2>Dibuat untuk sesi panjang</h2>
            <div className="grid3">
              {features.map(([t, d, c]) => (
                <div className={`tile ${c}`} key={t}><h3>{t}</h3><p>{d}</p></div>
              ))}
            </div>
          </div>
        </section>

        <section id="unduh" className="band accent">
          <div className="wrap download">
            <h2>Siap merapikan folder unduhan?</h2>
            <p>Pilih installer atau versi portabel yang tinggal diekstrak. Keduanya tanpa akun dan tanpa iklan.</p>
            <div className="cta">
              <a className="btn dark" href={SETUP}>Installer (.exe)</a>
              <a className="btn light" href={ZIP}>Portabel (.zip)</a>
              <a className="btn light" href={REL} target="_blank" rel="noreferrer">Semua rilis</a>
            </div>
            <p className="note">Installer belum ditandatangani, jadi Windows SmartScreen bisa menampilkan peringatan "publisher tidak dikenal". Pilih "More info" lalu "Run anyway".</p>
          </div>
        </section>
      </main>

      <footer>Rename Peek · dibuat dengan Flutter · <a href={REPO} target="_blank" rel="noreferrer">Kode sumber</a></footer>
    </>
  );
}
