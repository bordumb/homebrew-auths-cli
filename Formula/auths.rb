class Auths < Formula
  desc "Git-native identity and access management with cryptographic commit signing"
  homepage "https://docs.auths.dev"
  version "0.0.1-rc.9"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-macos-aarch64.tar.gz"
      sha256 "3eb1abf394b008e02b6f4ba576c45c537470bd087d615d10dbc16b7112b34bcb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-linux-x86_64.tar.gz"
      sha256 "afd3d6be0406ec285a7de1c847ff27f1442389a23de8caa2dd088f5377fc0256"
    end
    on_arm do
      url "https://github.com/bordumb/auths-releases/releases/download/v#{version}/auths-linux-aarch64.tar.gz"
      sha256 "1f96526f02d760d8ee384d6ed1c9c4afbc94702203f6ba1b30c206a153bac6cc"
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
