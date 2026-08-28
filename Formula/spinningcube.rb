class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-macos-arm64.tar.gz"
      sha256 "9dffe6f8f4523739a05f1e3750c3968526d1f2aab255efffe5503a1ddff08e91"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-macos-x86_64.tar.gz"
      sha256 "c342cd6b31744865ded9402e011670c7ac1fd3067a1e3ff15d19f193634ad73d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-linux-x86_64.tar.gz"
      sha256 "5137f462ab2526a7649d2f1f5d7a3cd2037c01217823b1deefc4f8cbf0799276"
    end
  end

  def install
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
