{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "spire-controller-manager";
  version = "0.8.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "spiffe";
    repo = "spire-controller-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uyh9XdqKiTSzgO2Y2wFhtWZSl9F9/63qZEMrfrnH4Ug=";
  };

  vendorHash = "sha256-Xid0cD6xW1f4tc3U89e66E6wpxCNsuclislg4pRzWRM=";

  ldflags = [ "-s" ];

  subPackages = [ "cmd" ];

  postInstall = ''
    mv "$out/bin/cmd" "$out/bin/spire-controller-manager"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kubernetes controller manager that reconciles workload registration and federation relationships";
    homepage = "https://github.com/spiffe/spire-controller-manager";
    changelog = "https://github.com/spiffe/spire-controller-manager/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "spire-controller-manager";
  };
})
