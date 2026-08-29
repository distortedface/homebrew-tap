class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.2/spinningcube-macos-arm64.tar.gz"
      sha256 "55f3cbc0db8f387729b594571e4b2f3a87a6f8020958bfd8ae8e137072a0e2bc"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.2/spinningcube-macos-x86_64.tar.gz"
      sha256 "903864bd7b701f7d56bdcca22061f032a63694429b3a99302b1d6bd7a9162dcb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.2/spinningcube-linux-x86_64.tar.gz"
      sha256 "fd7f8da7d98b7a1e10909a6982c8a5653054f7e2fec242017a70d3342ec41f07"
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
