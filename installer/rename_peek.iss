; Installer Rename Peek (Inno Setup 6). Dibuat lewat installer\build_installer.ps1
; Instal per-pengguna tanpa admin secara default; pengguna bisa memilih instal untuk semua pengguna.

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#define AppName "Rename Peek"
#define AppExe "rename_peek.exe"
#define StageDir "..\build\installer_stage"

[Setup]
AppId={{6F3B8E1A-2C47-4D9B-9A55-7E0C41B2D8F3}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Bayu-Pasifik
AppPublisherURL=https://github.com/Bayu-Pasifik/rename-peek
AppSupportURL=https://github.com/Bayu-Pasifik/rename-peek/issues
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
OutputDir=..\build\installer
OutputBaseFilename=RenamePeek-Setup-{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
MinVersion=10.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
SetupAppTitle=Pasang {#AppName}
SetupWindowTitle=Pasang - %1
UninstallAppTitle=Hapus {#AppName}
UninstallAppFullTitle=Hapus %1
ButtonBack=< &Kembali
ButtonNext=&Lanjut >
ButtonInstall=&Pasang
ButtonFinish=&Selesai
ButtonCancel=Batal
WelcomeLabel1=Selamat datang di Pemasang [name]
WelcomeLabel2=[name/ver] akan dipasang di komputer ini.%n%nAplikasi untuk mengganti nama file hasil unduhan yang bernama sama (dokumen, dokumen (1), dokumen (2), ...) dengan preview di dalam aplikasi.%n%nTutup aplikasi lain sebelum melanjutkan.
SelectDirDesc=Di mana [name] akan dipasang?
SelectDirLabel3=Pemasang akan memasang [name] di folder berikut.
SelectDirBrowseLabel=Klik Lanjut untuk meneruskan. Untuk memilih folder lain, klik Telusuri.
ButtonBrowse=&Telusuri...
SelectTasksDesc=Pilih tugas tambahan yang diinginkan.
SelectTasksLabel2=Pilih tugas tambahan yang dijalankan saat memasang [name], lalu klik Lanjut.
ReadyLabel1=Pemasang siap memasang [name] di komputer ini.
ReadyLabel2a=Klik Pasang untuk melanjutkan, atau Kembali untuk mengubah pengaturan.
InstallingLabel=Mohon tunggu, [name] sedang dipasang.
FinishedHeadingLabel=Pemasangan [name] selesai
FinishedLabelNoIcons=[name] sudah terpasang di komputer ini.
FinishedLabel=[name] sudah terpasang. Aplikasi bisa dijalankan lewat pintasan yang dibuat.
ConfirmUninstall=Yakin ingin menghapus %1 beserta semua komponennya?
UninstalledAll=%1 berhasil dihapus dari komputer ini.

[CustomMessages]
english.DesktopIcon=Buat pintasan di &Desktop
english.LaunchApp=Jalankan {#AppName}

[Tasks]
Name: "desktopicon"; Description: "{cm:DesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#StageDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent
