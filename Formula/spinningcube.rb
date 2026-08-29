class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.1/spinningcube-macos-arm64.tar.gz"
      sha256 "472c1d2723a1d798561d4547b960cd532399091da845bf9ecf1959f8d711d324"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.1/spinningcube-macos-x86_64.tar.gz"
      sha256 "83cf0ba1d32ebf1e3ba92c0a9488ab9031a718da9582a1ceb4e3cfbb0db3b011"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.1/spinningcube-linux-x86_64.tar.gz"
      sha256 "a8503a143080e2cb6bfbd62631c0dec5342a708f5643b24678fe0f81120b1534"
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
