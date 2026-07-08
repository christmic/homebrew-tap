# typed: false
# frozen_string_literal: true

class Token9 < Formula
  desc "Transparent LLM gateway — local API router & token meter"
  homepage "https://github.com/christmic/token9"
  head "https://github.com/christmic/token9.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "token9-server"
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
