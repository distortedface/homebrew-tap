require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.31"
  license "Apache-2.0"

  depends_on "cosign" => :build

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.31/spinningcube-macos-arm64.tar.gz"
      sha256 "0dadc9adf9b4daef448f7aa7e8b42781c188c7053d0201d89ad1c175107ab5c7"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.31/spinningcube-macos-x86_64.tar.gz"
      sha256 "9ee6fd4ef5cf29516ff710bb2259e902878e634bc2861bfb59f2a8c3e23a8c6b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.31/spinningcube-linux-x86_64.tar.gz"
      sha256 "5371bf7ebe74f949ae83c457921e59bd1998dfd10ce3f83bd41cdd65312dbbf8"
    end
  end

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.31/release-manifest.json"
    sha256 "bf9d6d41f34696519c356f0689b6fbf96abf663c216214a70a6d7c9ddd83820d"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.31/release-manifest.sigstore.json"
    sha256 "169cd21648ef1c615cbed8e4c971b74fd1bf2170e7955e3cc82944b27386bd98"
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system formula_opt_bin("cosign")/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.31",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" if manifest.fetch("version") != "cli-v0.1.31"
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
