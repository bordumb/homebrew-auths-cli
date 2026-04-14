class Auths < Formula
  desc "Cryptographic identity for developers — sign artifacts, replace API keys"
  homepage "https://auths.dev"
  version "0.0.1-rc.12"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-macos-aarch64.tar.gz"
      sha256 "adcb49b5d900cbc6c97d4173154c3e3fc188a80d5f14730de1d208eceba6b2fe"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-linux-x86_64.tar.gz"
      sha256 "73f3054eee1eddce76f96bb3b9017de7bd8250e328ab09c975812303e6473bd0"
    end
    on_arm do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-linux-aarch64.tar.gz"
      sha256 "80df040676976f5e25d08d19d949193711b17f9a3cf532947c4da652407c9112"
    end
  end

  def install
    bin.install "auths"
    bin.install "auths-sign" if File.exist?("auths-sign")
    bin.install "auths-verify" if File.exist?("auths-verify")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/auths --version")
  end
end
