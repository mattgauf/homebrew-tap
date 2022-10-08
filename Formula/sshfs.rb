class Sshfs < Formula
  desc "File system client based on SSH File Transfer Protocol"
  homepage "https://osxfuse.github.io/"
  url "https://github.com/libfuse/sshfs/archive/sshfs-3.7.3.tar.gz"
  sha256 "52a1a1e017859dfe72a550e6fef8ad4f8703ce312ae165f74b579fd7344e3a26"
  license "GPL-2.0"
  revision 3

  bottle do
    sha256 x86_64_linux: "a98d273e64706971684935a3ae87da16b1dda98f7289eb79e82f4cdfb7f12bb8"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"

  # on_macos do
  #   disable! date: "2021-04-08", because: "requires FUSE"
  # end

  on_linux do
    depends_on "libfuse"
  end

  # Apply patch that clears one remaining roadblock that prevented setting
  # a custom I/O buffer size on macOS. With this patch in place, it's
  # recommended to use e.g. `-o iosize=1048576` (or other, reasonable value)
  # when launching `sshfs`, for improved performance.
  # See also: https://github.com/libfuse/sshfs/issues/11
  # patch do
  #   url "https://github.com/libfuse/sshfs/commit/667cf34622e2e873db776791df275c7a582d6295.patch?full_index=1"
  #   sha256 "ab2aa697d66457bf8a3f469e89572165b58edb0771aa1e9c2070f54071fad5f6"
  # end

  def install
    mkdir "build" do
      system "meson", ".."
      system "meson", "configure", "--prefix", prefix
      system "ninja", "--verbose"
      system "ninja", "install", "--verbose"
    end
  end

  test do
    system "#{bin}/sshfs", "--version"
  end
end
