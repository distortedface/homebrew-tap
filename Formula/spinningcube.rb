require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.56"
  license "Apache-2.0"

  depends_on "cosign" => :build

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.56/spinningcube-macos-arm64.tar.gz"
      sha256 "b75ad85c9282646073c1c22eb08de5182ef2b7a07bfca8e0749eeb03272fa8db"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.56/spinningcube-macos-x86_64.tar.gz"
      sha256 "715eec9159a74b7cd96660aeacc0d5e463b323436858485e873e43d0735b6923"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.56/spinningcube-linux-x86_64.tar.gz"
      sha256 "2dd910b131592a1e1f0dcd21495e7f8913e6e1997ec5aae2fa8dd8a46ab72e06"
    end
  end

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.56/release-manifest.json"
    sha256 "83cb20873dc0d7ffec1ad989fe8163fb8347c44bb337e8d5ec8ee4954cbcaa73"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.56/release-manifest.sigstore.json"
    sha256 "c5088c385ce93a3ec5a99185dd38573861936b7ca30c0d670aa14f7eb722c1b0"
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system formula_opt_bin("cosign")/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.56",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" if manifest.fetch("version") != "cli-v0.1.56"
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
