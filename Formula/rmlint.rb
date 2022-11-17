class Rmlint < Formula
  desc "Extremely fast tool to remove dupes and other lint from your filesystem"
  homepage "https://github.com/sahib/rmlint"
  url "https://github.com/SeeSpotRun/rmlint/archive/macport.tar.gz"
  version "20210527"
  sha256 "822b7b2d7f62ae2790e075282100f0c01ba7a07e4e6c8b11fa9bc51226cc4b2b"
  license "GPL-3.0-or-later"

  option "with-gui", "Also build 'shredder' gui for rmlint"
  bottle do
    sha256 cellar: :any, arm64_big_sur: "4a8bd2357b069ad4be2327e14569931add4a6063f7642cc5a50ee0918e752362"
    sha256 cellar: :any, big_sur:       "1f6f76bfe7c4f4c058b91a0808e6e19a0029f4a4017929615bc223666abddf5a"
    sha256 cellar: :any, catalina:      "38f621eb2196afa5504087ef48cd19777efbd5da81302ea668b0efbd68cc20d7"
    sha256 cellar: :any, mojave:        "e7eac7ed5d93b19175c7860fe84faa34f878253c15bdbc280ee06cfd392f10e3"
    sha256 cellar: :any, high_sierra:   "b84e9cd89ef6b9d43f633226e0a7ecb85e5c75c65f3b50f83cf687862db8d191"
  end

  depends_on "gettext" => :build
  depends_on "pkg-config" => :build
  depends_on "scons" => :build
  depends_on "sphinx-doc" => :build
  #depends_on "glib"
  depends_on "json-glib"
  depends_on "libelf"
  if build.with? "gui"
    # gui dependencies:
    depends_on "pygobject3"
    #depends_on "gtk+3"
    #depends_on "gobject-introspection"
    #depends_on "librsvg"
    #depends_on "xorg-server"
    #depends_on "gsettings-desktop-schemas"
    depends_on "gtksourceview3"
    #depends_on "hicolor-icon-theme"
    #depends_on "gnome-icon-theme"
    depends_on "adwaita-icon-theme"
  end

  def install
    # patch to address bug affecting High Sierra & Mojave introduced in rmlint v2.10.0
    # may be removed once the following issue / pull request are resolved & merged:
    #   https://github.com/sahib/rmlint/issues/438
    #   https://github.com/sahib/rmlint/pull/444
    if MacOS.version < :catalina
      inreplace "lib/cfg.c",
      "    rc = faccessat(AT_FDCWD, path, R_OK, AT_EACCESS|AT_SYMLINK_NOFOLLOW);",
      "    rc = faccessat(AT_FDCWD, path, R_OK, AT_EACCESS);"
    end

    if build.with? "gui"
      system "scons", "config"
      system "scons", "--prefix=#{prefix}/", "install", "--without-schemas-compile"
    else
      system "scons", "--without-gui", "config"
      system "scons", "--without-gui", "--prefix=#{prefix}/", "install"
    end
  end

  def post_install
    if build.with? "gui"
      system "#{Formula["glib"].opt_bin}/glib-compile-schemas",
        "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
      system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t",
        "#{HOMEBREW_PREFIX}/share/icons/hicolor"
      system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t",
        "#{HOMEBREW_PREFIX}/share/icons/Adwaita"
    end
  end

  test do
    (testpath/"1.txt").write("1")
    (testpath/"2.txt").write("1")
    assert_match "# Duplicate(s):", shell_output("#{bin}/rmlint")
  end
end
