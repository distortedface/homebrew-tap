class Spinningcube < Formula
  desc "Repository-bound local verification authority for SpinningCube.run"
  homepage "https://spinningcube.run"
  version "0.1.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.3/spinningcube-macos-arm64.tar.gz"
      sha256 "733594a03475e7bde483658feca6f88439eedb27527570e9bce723b0225da53e"
    else
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.3/spinningcube-macos-x86_64.tar.gz"
      sha256 "97e8ab515c34a5c430db976a7ecfcd79527583c6584f26e3b0bbab9cc426acc5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/distortedface/homebrew-tap/releases/download/cli-v0.1.3/spinningcube-linux-x86_64.tar.gz"
      sha256 "afbc6ffced9a532a0fe0709836f07fd1ff91d3484c9d41e604691ab70eee73a4"
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
