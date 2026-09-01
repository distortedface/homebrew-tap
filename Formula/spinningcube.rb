require "digest"
require "json"

class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.23"
  license "Apache-2.0"

  depends_on "cosign" => :build

  resource "release-manifest" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.23/release-manifest.json"
    sha256 "14b88ef8844da33dfc046da67ca40d227b0b6266229c30c6b69160dfa02fa787"
  end

  resource "release-manifest-bundle" do
    url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.23/release-manifest.sigstore.json"
    sha256 "cedf90040894dce99a457ab23c1d559cdddc8b45f0f47a3edad4400f4060a640"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.23/spinningcube-macos-arm64.tar.gz"
      sha256 "6b1506e20159df6705fe1036cf22d23389f950412d559b22a8c943d38cc72230"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.23/spinningcube-macos-x86_64.tar.gz"
      sha256 "aff5ae765a1815ad105acbb08c39ad6ffa55c08d6bd475dc5c6329fe79583dad"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.23/spinningcube-linux-x86_64.tar.gz"
      sha256 "ba3c8fe1fa8501e9115f3bc0ebf09a049e986c3621d1552bbb3a372fdaf67f11"
    end
  end

  def install
    manifest_path = resource("release-manifest").cached_download
    bundle_path = resource("release-manifest-bundle").cached_download
    system Formula["cosign"].opt_bin/"cosign", "verify-blob",
      "--bundle", bundle_path,
      "--certificate-identity", "https://github.com/distortedface/SpinningCube.run/.github/workflows/release-cli.yml@refs/tags/cli-v0.1.23",
      "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
      manifest_path
    manifest = JSON.parse(File.read(manifest_path))
    odie "release manifest version mismatch" unless manifest.fetch("version") == "cli-v0.1.23"
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
    odie "release binary does not match signed manifest" unless actual == artifact.fetch("binary_sha256")
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
