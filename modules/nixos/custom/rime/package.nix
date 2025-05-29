{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rime";
  version = "0.1.8-unstable-2025-05-23";

  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitHub {
    owner = "cafkafk";
    repo = "rime";
    rev = "b84f6795d0dec05651a315a67f9e76c9b17861e10";
    hash = "sha256-/aMOmUGp8pHK119YwYc6HBL2ZLvSsjjYAVqO3K7ElBc=";
  };

  cargoHash = "sha256-HkQpluiWQo/itU7/hVK6D5pfOD1KBppPPmwYMNHSfmk=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [ openssl ];

  env = {
    MAN_OUT = "man";
  };

  preBuild = ''
    mkdir -p "$MAN_OUT"
  '';

  postInstall = ''
    installManPage man/rime.1

    installShellCompletion \
      --bash man/rime.bash \
      --fish man/rime.fish \
      --zsh  man/_rime
  '';

  meta = {
    description = "Nix Flake Input Versioning";
    homepage = "https://github.com/cafkafk/rime";
    changelog = "https://github.com/cafkafk/rime/releases/tag/v0.1.8";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "rime";
    platforms = lib.platforms.unix;
  };
})
