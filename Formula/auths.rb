class Auths < Formula
  desc "Git-native identity and access management with cryptographic commit signing"
  homepage "https://docs.auths.dev"
  version "0.0.1-rc.6"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/bordumb/auths/releases/download/v#{version}/auths-macos-x86_64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_X86_64"
    elsif Hardware::CPU.arm?
      url "https://github.com/bordumb/auths/releases/download/v#{version}/auths-macos-aarch64.tar.gz"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_ARM64"
    end
  end

  def install
    bin.install "auths"
    bin.install "auths-sign"
    bin.install "auths-verify"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/auths --version")
  end
end
