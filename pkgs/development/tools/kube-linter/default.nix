{ lib, buildGoModule, fetchFromGitHub, installShellFiles, testers, kube-linter }:

buildGoModule rec {
  pname = "kube-linter";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "stackrox";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-REUjvIiHASiFQyzU/4n9wPkvaVGmaU/2MBqIBjtWhdY=";
  };

  vendorHash = "sha256-ATGSIwjmqRuqn+6VTBvjdfXbcABEdaf5HEsaS2o2V3o=";

  ldflags = [
    "-s" "-w" "-X golang.stackrox.io/kube-linter/internal/version.version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  checkFlags = [ "-skip=TestCreateContextsWithIgnorePaths" ];

  postInstall = ''
    installShellCompletion --cmd kube-linter \
      --bash <($out/bin/kube-linter completion bash) \
      --fish <($out/bin/kube-linter completion fish) \
      --zsh <($out/bin/kube-linter completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = kube-linter;
    command = "kube-linter version";
  };

  meta = with lib; {
    description = "A static analysis tool that checks Kubernetes YAML files and Helm charts";
    homepage = "https://kubelinter.io";
    changelog   = "https://github.com/stackrox/kube-linter/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ mtesseract stehessel Intuinewin ];
    platforms = platforms.all;
  };
}
