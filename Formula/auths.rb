class Auths < Formula
  desc "Cryptographic identity for developers — sign artifacts, replace API keys"
  homepage "https://auths.dev"
  version "0.1.16"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-macos-aarch64.tar.gz"
      sha256 "cc5c13d30eda9e971dde9906a7c76d54b73ebd397b499180098e8e94eff43cc9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-linux-x86_64.tar.gz"
      sha256 "aaf6ae18bae6ba7db5e4ea1edcbee37d7138fd7ace19073be0a7b400b208102a"
    end
    on_arm do
      url "https://github.com/auths-dev/auths/releases/download/v#{version}/auths-linux-aarch64.tar.gz"
      sha256 "35fa2fc92fe6f601782c11d11fcc1858f045ba19f9fcf7c1cb96b9e45025c90f"
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
