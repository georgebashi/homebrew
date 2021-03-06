require 'formula'

class Jasper < Formula
  homepage 'http://slackware.sukkology.net/packages/jasper/'
  url 'http://slackware.sukkology.net/packages/jasper/jasper-1.900.1.zip'
  md5 'a342b2b4495b3e1394e161eb5d85d754'

  depends_on 'jpeg'

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def options
    [["--universal", "Build a universal binary."]]
  end

  # The following patch fixes a bug (still in upstream as of jasper 1.900.1)
  # where an assertion fails when Jasper is fed certain JPEG-2000 files with
  # an alpha channel. See:
  # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=469786
  def patches; DATA; end

  def install
    ENV.universal_binary if ARGV.build_universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-shared",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make install"
  end
end

__END__
diff --git a/src/libjasper/jpc/jpc_dec.c b/src/libjasper/jpc/jpc_dec.c
index fa72a0e..1f4845f 100644
--- a/src/libjasper/jpc/jpc_dec.c
+++ b/src/libjasper/jpc/jpc_dec.c
@@ -1069,12 +1069,18 @@ static int jpc_dec_tiledecode(jpc_dec_t *dec, jpc_dec_tile_t *tile)
	/* Apply an inverse intercomponent transform if necessary. */
	switch (tile->cp->mctid) {
	case JPC_MCT_RCT:
-		assert(dec->numcomps == 3);
+		if (dec->numcomps != 3 && dec->numcomps != 4) {
+			jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+			return -1;
+		}
		jpc_irct(tile->tcomps[0].data, tile->tcomps[1].data,
		  tile->tcomps[2].data);
		break;
	case JPC_MCT_ICT:
-		assert(dec->numcomps == 3);
+		if (dec->numcomps != 3 && dec->numcomps != 4) {
+			jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+			return -1;
+		}
		jpc_iict(tile->tcomps[0].data, tile->tcomps[1].data,
		  tile->tcomps[2].data);
		break;
