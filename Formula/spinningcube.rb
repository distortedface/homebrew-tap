require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.51"
  license "Apache-2.0"

  depends_on "cosign" => :build

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.51/spinningcube-macos-arm64.tar.gz"
      sha256 "049bc1e064ee88ad420e11e8dddd9bacc22759f6fa71dd1381e3067e46db76fa"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.51/spinningcube-macos-x86_64.tar.gz"
      sha256 "1c2bc9e358c33b6c7b37d54fb5049b07cba51eb07181abbdf0f7c55dae9543db"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.51/spinningcube-linux-x86_64.tar.gz"
      sha256 "45af20c4b198ad74ba08e0ee4a63e34690c47148db99414aedeafe5fbf231d3f"
    end
  end

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.51/release-manifest.json"
    sha256 "c5d09c0d71b6e42bea21ac876f82cb29f85214c9b0d3986021a5646fa7c81443"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.51/release-manifest.sigstore.json"
    sha256 "768edd340d79e3eb1acfd4ab9ed87065fbd1eb3a982dff54e83d8c14700c2048"
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system formula_opt_bin("cosign")/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.51",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" if manifest.fetch("version") != "cli-v0.1.51"
    asset = if OS.mac? && Hardware::CPU.arm?
      "spinningcube-macos-arm64.tar.gz"
    elsif OS.mac?
      "spinningcube-macos-x86_64.tar.gz"
    else
      "spinningcube-linux-x86_64.tar.gz"
    end
    artifact = manifest.fetch("artifacts").find { |entry| entry["name"] == asset }
    odie "release manifest does not authorize this binary" unless artifact
    actual = Digest::SHA256.file("spinningcube").hexdigest
    odie "release binary does not match signed manifest" if actual != artifact.fetch("binary_sha256")
    bin.install "spinningcube"
  end

  def caveats
    <<~EOS
      Run `spinningcube setup` once to verify Git and Docker.
      Host compilers are deliberately ignored; exact compilers run in Docker.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/spinningcube --version")
  end
end
