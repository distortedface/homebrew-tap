class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-macos-arm64.tar.gz"
      sha256 "9a5c21c19e426603ee674247880add23c73d70736324d7f9569a0b73bd6fbd97"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-macos-x86_64.tar.gz"
      sha256 "1cd435588f093f888c013a0c781dd49f1f6df0b252e8ee44db05e905fde1260c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.0/spinningcube-linux-x86_64.tar.gz"
      sha256 "93bd13568b9f39d15de9d809efe420d10318980f71efdb08651865cf3626e5c4"
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
