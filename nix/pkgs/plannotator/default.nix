{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.26.2";

  # The project publishes prebuilt standalone binaries on GitHub releases,
  # compiled with `bun build --compile` (self-contained, no runtime deps).
  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "plannotator: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if stdenv.hostPlatform.isx86_64 then
      "x64"
    else if
      stdenv.hostPlatform.isAarch64
      || stdenv.hostPlatform.isAarch32
    then
      "arm64"
    else
      throw "plannotator: unsupported arch ${stdenv.hostPlatform.system}";

  # sha256 for each supported platform's release binary.
  sha256BySystem = {
    "x86_64-linux" = "sha256-Q5NeFmATSBr6Y01mR6y60kkSTbr2FKT4ZZ7M5fluQpE=";
    "aarch64-linux" = "sha256-UPwsSou9CLsavZZ5o6wn4Gzu5IEz0dGzV5VCjzuag04=";
    "x86_64-darwin" = "sha256-T2i9sJ7jSPWG2p9EKUlVPQxX1qfVT25/rM6mGcV96lY=";
    "aarch64-darwin" = "sha256-JNjwu82O/s+hJa0O0IxzyFHtI3vdVNx0sE7xpj7wnhQ=";
  };

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${os}-${arch}";
    sha256 = sha256BySystem.${stdenv.hostPlatform.system} or (throw "plannotator: missing sha256 for ${stdenv.hostPlatform.system}");
  };
in
stdenv.mkDerivation {
  pname = "plannotator";
  inherit version;

  inherit src;

  dontUnpack = true;
  dontBuild = true;

  # The prebuilt binary is a single-file Bun executable. Nixpkgs' default
  # `strip` phase corrupts it (removes the embedded bundle, turning it into a
  # bare Bun CLI), so the binary must be left untouched.
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp "$src" "$out/bin/plannotator"
    chmod +x "$out/bin/plannotator"
    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Annotate and review coding agent plans and code diffs visually";
    homepage = "https://plannotator.ai";
    changelog = "https://github.com/backnotprop/plannotator/releases";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "plannotator";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}