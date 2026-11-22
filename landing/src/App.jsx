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
  ['Lihat isinya', 'Preview file muncul langsung, tanpa membuka aplikasi lain.'],
  ['Ketik lalu Enter', 'Nama baru tersimpan dan aplikasi lompat ke file berikutnya.'],
];

const faqs = [
  ['Apakah gratis?', 'Ya. Tanpa akun, tanpa iklan, tanpa langganan. Kode sumber terbuka di GitHub.'],
  ['Apakah file saya diunggah ke server?', 'Tidak. Semua berjalan lokal di PC Anda. Tidak ada koneksi internet yang dibutuhkan.'],
  ['Preview Word dan Excel butuh apa?', 'Microsoft Office terpasang di PC. PDF, gambar, dan teks tidak butuh apa pun.'],
  ['Windows menampilkan peringatan SmartScreen?', 'Installer belum ditandatangani. Pilih "More info" lalu "Run anyway".'],
];

function Mock() {
  return (
    <div className="mock" aria-hidden="true">
      <div className="mock-bar">
        <i /><i /><i />
        <span>Rename Peek</span>
      </div>
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

function initialTheme() {
  try {
    const saved = localStorage.getItem('theme');
    if (saved === 'light' || saved === 'dark') return saved;
  } catch (e) { /* ignore */ }
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export default function App() {
  const [theme, setTheme] = React.useState(initialTheme);
  React.useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);
  const toggle = () => {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    try { localStorage.setItem('theme', next); } catch (e) { /* ignore */ }
  };
  return (
    <div id="top">
      <header className="nav">
        <div className="wrap nav-in">
          <a className="brand" href="#top"><span className="logo" />Rename Peek</a>
          <nav>
            <a href="#fitur">Fitur</a>
            <a href="#cara">Cara pakai</a>
            <a href="#harga">Harga</a>
            <a href="#faq">FAQ</a>
          </nav>
          <div className="nav-act">
            <button type="button" className="theme-btn" onClick={toggle} aria-label="Ganti tema terang/gelap">
              {theme === 'dark' ? 'Terang' : 'Gelap'}
            </button>
            <a className="btn sm" href={SETUP}>Unduh</a>
          </div>
        </div>
      </header>

      <main>
        <section className="hero wrap">
          <span className="pill">v1.1.0 · Windows 10/11 · Open source</span>
          <h1>Lihat dulu, baru beri nama</h1>
          <p className="sub">
            Puluhan file bernama <i>dokumen (1)</i>, <i>dokumen (2)</i> tak perlu dibuka satu per satu.
            Rename Peek menampilkan isinya. Ketik nama, tekan Enter, selesai.
          </p>
          <div className="cta">
            <a className="btn" href={SETUP}>Unduh untuk Windows</a>
            <a className="btn ghost" href={REPO} target="_blank" rel="noreferrer">Lihat di GitHub</a>
          </div>
          <p className="note">Gratis. Tanpa akun. Berjalan lokal.</p>
          <Mock />
        </section>

        <section className="stats wrap">
          <div><b>PDF · Word · Excel</b><span>plus gambar dan teks</span></div>
          <div><b>0 unggahan</b><span>semua di PC Anda</span></div>
          <div><b>Ctrl+Z</b><span>undo, tahan restart</span></div>
        </section>

        <section id="fitur" className="sec wrap">
          <h2>Semua yang dibutuhkan untuk merapikan unduhan</h2>
          <p className="lead">Dibuat untuk satu pekerjaan, dan dikerjakan dengan cepat.</p>
          <div className="grid3">
            {features.map(([t, d]) => (
              <article className="card" key={t}>
                <h3>{t}</h3>
                <p>{d}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="cara" className="sec wrap">
          <h2>Tiga langkah</h2>
          <div className="grid3">
            {steps.map(([t, d], i) => (
              <article className="card step" key={t}>
                <span className="num">{i + 1}</span>
                <h3>{t}</h3>
                <p>{d}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="harga" className="sec wrap">
          <h2>Harga</h2>
          <div className="price">
            <div>
              <span className="pill">Semua fitur</span>
              <p className="amount">Rp0 <small>selamanya</small></p>
              <ul>
                <li>Preview PDF, Office, gambar, teks</li>
                <li>Undo berlapis dan riwayat</li>
                <li>Tanpa akun, tanpa iklan</li>
              </ul>
            </div>
            <div className="price-cta">
              <a className="btn" href={SETUP}>Installer (.exe)</a>
              <a className="btn ghost" href={ZIP}>Portabel (.zip)</a>
              <a className="more" href={REL} target="_blank" rel="noreferrer">Semua rilis</a>
            </div>
          </div>
        </section>

        <section id="faq" className="sec wrap narrow">
          <h2>Pertanyaan umum</h2>
          {faqs.map(([q, a]) => (
            <details key={q}>
              <summary>{q}</summary>
              <p>{a}</p>
            </details>
          ))}
        </section>

        <section className="final wrap">
          <h2>Siap merapikan folder unduhan?</h2>
          <a className="btn" href={SETUP}>Unduh Rename Peek</a>
        </section>
      </main>

      <footer className="wrap foot">
        <span>Rename Peek · dibuat dengan Flutter</span>
        <a href={REPO} target="_blank" rel="noreferrer">GitHub</a>
      </footer>
    </div>
  );
}
