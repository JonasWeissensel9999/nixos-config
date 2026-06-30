{
  fetchFromGitHub,
  rustPlatform,
  git,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-mob";
  version = "1.9.3";

  nativeBuildInputs = [ git ];

  src = fetchFromGitHub {
    owner = "Mubashwer";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0NSGObflI1iiRp/lVkD8RhUKS+He1ERAZUHxcU0EI8M=";
  };

  # inherit cargoLock;

  # cargoLock = {
  # lockFile = ./Cargo.lock;
  #   outputHashes = { };
  # };
  cargoHash = "sha256-0+JASgFPO7gbIeJmPskPSirMec89qSoa0461SuIxwNA=";

  meta = {
    description = "CLI tool to automatically add Co-authored-by trailers to git commits during pair/mob programming";
    homepage = "https://github.com/Mubashwer/git-mob";
    maintainers = [ ];
  };
}
