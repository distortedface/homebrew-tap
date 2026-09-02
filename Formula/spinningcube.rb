require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.34"
  license "Apache-2.0"

  depends_on "cosign" => :build

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.34/spinningcube-macos-arm64.tar.gz"
      sha256 "d7863d8ffa00b61a95b8a33099afd310742ec869c416e759fedb281570e19bbe"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.34/spinningcube-macos-x86_64.tar.gz"
      sha256 "dd26ee00ba7c88673981cce1db3b5e31e1fe3f4e6698a947effc7b0e1933d8c7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.34/spinningcube-linux-x86_64.tar.gz"
      sha256 "821d8b46ba1abd6a3aafc1b1d43de4c98cf424fde1aae8d1cf014f18e9a66e43"
    end
  end

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.34/release-manifest.json"
    sha256 "1e9854a9c313b102a803352a93f705b3ac11df0cff6812f7d24a9e36ab8be0d6"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.34/release-manifest.sigstore.json"
    sha256 "b17de780662f9f9b26ce345b5678e722856372c6b0c4e881d3e7fb8ee6f59e84"
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system formula_opt_bin("cosign")/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.34",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" if manifest.fetch("version") != "cli-v0.1.34"
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
