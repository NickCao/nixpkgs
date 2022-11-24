{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "consul-dataplane";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Qmh4PU3yUfv7wFBEKSnNFJsfaDH80OHiFZ3vo7ZmIvo=";
  };

  vendorHash = "sha256-9KWcacmkDu1R72Lm1gQfSNoQlCx7jjkythgUcOWTf10=";

  subPackages = [ "cmd/consul-dataplane" ];

  meta = with lib; {
    description = "Consul Dataplane is a lightweight process that manages Envoy for Consul service mesh workloads";
    homepage = "https://www.consul.io/";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.mpl20;
    maintainers = with maintainers; [ nickcao ];
  };
}
