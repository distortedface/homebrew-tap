require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.59"
  license "Apache-2.0"

  depends_on "cosign" => :build

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.59/spinningcube-macos-arm64.tar.gz"
      sha256 "cdefcdc3514a4ce92f9f4aa0d48e06292dbf71d72eb1b8f2a2105350adb0e652"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.59/spinningcube-macos-x86_64.tar.gz"
      sha256 "5f9a632e70e8a66eebde02ce488354c777a4a36ea58c9efafd41bbe72297a97d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.59/spinningcube-linux-x86_64.tar.gz"
      sha256 "e024c399238976f354c5bd47b6faffe35568d7654b17eb89fc1f44659d0ec9ef"
    end
  end

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.59/release-manifest.json"
    sha256 "b119a34bc6959f6c69c2dea2cc5d99d8418b02dd6848289cf05622714f077443"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.59/release-manifest.sigstore.json"
    sha256 "77d9aa47bb61cc8e22b87a51e43189805154e4fcf295bc497dd7d0ee296ac3cc"
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system formula_opt_bin("cosign")/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.59",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" if manifest.fetch("version") != "cli-v0.1.59"
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
