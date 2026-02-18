class Auths < Formula
  desc "Git-native identity and access management with cryptographic commit signing"
  homepage "https://docs.auths.dev"
  version "0.0.1-rc.11"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-macos-aarch64.tar.gz"
      sha256 "f1bdc4674b43d1502c0040f6b1b2df4f1818622b98c56bde0fad532b34485bfa"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-linux-x86_64.tar.gz"
      sha256 "5398ecebd6981f146ff53791aa42211866a43a372706593fd18533f709153d93"
    end
    on_arm do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-linux-aarch64.tar.gz"
      sha256 "c199bc049fe187a1d90819195adee97fa00e517586ad9a83d9d59b3287cfc89e"
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
