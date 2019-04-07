#!/bin/sh
# Run this to generate all the initial makefiles, etc.

# (c) 2003 Alexander Dunayevskyy
# MIT License


# ChangeLog:
#
# 2003/11/16: 0.1.1
# - AM_PROG_XXX changed to AC_PROG_XXX due to new autoconf syntax
# - added automake "--add-missing --copy" options


srcdir=`dirname $0`
PKG_NAME="the package."

DIE=0

(autoconf --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "**Error**: You must have \`autoconf' installed to."
	echo "Download the appropriate package for your distribution,"
	echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
	DIE=1
}

(grep "^AC_PROG_LIBTOOL" $srcdir/configure.in >/dev/null) && {
	(libtool --version) < /dev/null > /dev/null 2>&1 || {
		echo
		echo "**Error**: You must have \`libtool' installed."
	    echo "Get ftp://ftp.gnu.org/pub/gnu/libtool-1.2d.tar.gz"
	    echo "(or a newer version if it is available)"
		DIE=1
	}
}

grep "^AM_GNU_GETTEXT" $srcdir/configure.in >/dev/null && {
	grep "sed.*POTFILES" $srcdir/configure.in >/dev/null || \
	(gettext --version) < /dev/null > /dev/null 2>&1 || {
		echo
		echo "**Error**: You must have \`gettext' installed."
		echo "Get ftp://alpha.gnu.org/gnu/gettext-0.10.35.tar.gz"
		echo "(or a newer version if it is available)"
		DIE=1
	}
}

grep "^AM_GNOME_GETTEXT" $srcdir/configure.in >/dev/null && {
	grep "sed.*POTFILES" $srcdir/configure.in >/dev/null || \
	(gettext --version) < /dev/null > /dev/null 2>&1 || {
		echo
		echo "**Error**: You must have \`gettext' installed."
		echo "Get ftp://alpha.gnu.org/gnu/gettext-0.10.35.tar.gz"
		echo "(or a newer version if it is available)"
		DIE=1
	}
}

(automake --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "**Error**: You must have \`automake' installed."
	echo "Get ftp://ftp.gnu.org/pub/gnu/automake-1.3.tar.gz"
	echo "(or a newer version if it is available)"
	DIE=1
	NO_AUTOMAKE=yes
}


# if no automake, don't bother testing for aclocal
test -n "$NO_AUTOMAKE" || (aclocal --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "**Error**: Missing \`aclocal'.  The version of \`automake'"
	echo "installed doesn't appear recent enough."
	echo "Get ftp://ftp.gnu.org/pub/gnu/automake-1.3.tar.gz"
	echo "(or a newer version if it is available)"
	DIE=1
}

test "$DIE" -eq 1 && exit 1

if test -z "$*"; then
	echo "**Warning**: I am going to run \`configure' with no arguments."
	echo "If you wish to pass any to it, please specify them on the"
	echo \`$0\'" command line."
	echo
fi

case $CC in
xlc )
	am_opt=--include-deps;;
esac

am_opt="$am_opt --foreign --add-missing --copy"

for coin in `find $srcdir -name configure.in -print`
do
	dr=`dirname $coin`
	if test -f $dr/NO-AUTO-GEN; then
		echo skipping $dr -- flagged as no auto-gen
	else
		echo processing $dr
		macrodirs=`sed -n -e 's,AM_ACLOCAL_INCLUDE(\(.*\)),\1,gp' < $coin`
		( cd $dr
		aclocalinclude="$ACLOCAL_FLAGS"
		for k in $macrodirs; do
			if test -d $k; then
				aclocalinclude="$aclocalinclude -I $k"
			##else
			##  echo "**Warning**: No such directory \`$k'.  Ignored."
			fi
		done
    	if grep "^AM_GNU_GETTEXT" configure.in >/dev/null; then
			if grep "sed.*POTFILES" configure.in >/dev/null; then
			: do nothing -- we still have an old unmodified configure.in
			else
				echo "Creating $dr/aclocal.m4 ..."
				test -r $dr/aclocal.m4 || touch $dr/aclocal.m4
				echo "Running gettextize...  Ignore non-fatal messages."
				echo "no" | gettextize --force --copy
				echo "Making $dr/aclocal.m4 writable ..."
				test -r $dr/aclocal.m4 && chmod u+w $dr/aclocal.m4
			fi
		fi
		if grep "^AM_GNOME_GETTEXT" configure.in >/dev/null; then
			echo "Creating $dr/aclocal.m4 ..."
			test -r $dr/aclocal.m4 || touch $dr/aclocal.m4
			echo "Running gettextize...  Ignore non-fatal messages."
			echo "no" | gettextize --force --copy
			echo "Making $dr/aclocal.m4 writable ..."
			test -r $dr/aclocal.m4 && chmod u+w $dr/aclocal.m4
		fi
		if grep "^AC_PROG_LIBTOOL" configure.in >/dev/null; then
			echo "Running libtoolize..."
			libtoolize --force --copy  || exit 1
		fi
		echo "Running aclocal $aclocalinclude ..."
		aclocal $aclocalinclude
		if grep "^AC_CONFIG_HEADER" configure.in >/dev/null; then
			echo "Running autoheader..."
			autoheader  || exit 1
		fi
		echo "Running automake $am_opt ..."
		automake $am_opt  || exit 1
		echo "Running autoconf ..."
		autoconf  || exit 1
		)
	fi
done

#conf_flags="--enable-maintainer-mode --enable-compile-warnings" #--enable-iso-c

admin_dir=.
tmp=`grep AC_CONFIG_AUX_DIR configure.in 2>/dev/null | sed 's#AC_CONFIG_AUX_DIR##' | tr '[]()' '\n'`
test ! -z $tmp && admin_dir=$tmp

if test x$AUTOMOC = xyes; then
	echo "Postprocessing Makefile templates ..."
	perl -w $admin_dir/am_edit  || exit 1
fi

if test x$NOCONFIGURE = x; then
	echo Running $srcdir/configure $conf_flags "$@" ...
	$srcdir/configure $conf_flags "$@"  || exit 1
	#echo Now type \`make\' to compile $PKG_NAME
else
	echo Skipping configure process.
fi


exit 0
