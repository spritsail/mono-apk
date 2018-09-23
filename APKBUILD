# Contributor: Carlo Landmeter <clandmeter@gmail.com>
# Contributor: blattersturm <peachypies@protonmail.ch>
# Maintainer:  frebib <mono-apk@spritsail.io>
pkgname=mono
pkgver=5.14.0.177
pkgrel=2
pkgdesc="Free implementation of the .NET platform including runtime and compiler"
url="http://www.mono-project.com/"
arch="x86_64 x86"
license="GPL"
depends_dev="zlib-dev libgdiplus-dev"
makedepends="$depends_dev python2 linux-headers paxmark autoconf automake libtool cmake"
subpackages=" \
	$pkgname-dbg \
	$pkgname-dev \
	$pkgname-lang \
	$pkgname-corlib \
	$pkgname-runtime \
	$pkgname-runtime-doc:runtime_doc:noarch \
	lib$pkgname:libmono \
	ca-certificates-$pkgname:cacerts:noarch
	ca-certificates-$pkgname-doc:cacerts_doc:noarch
	$pkgname-utils:utils:noarch \
	$pkgname-csc:csc:noarch \
	$pkgname-xbuild:xbuild:noarch \
	$pkgname-doc \
	$pkgname-reference-assemblies-facades:assembliesfacades:noarch \
	$pkgname-reference-assemblies-api:assembliesapi:noarch \
	$pkgname-reference-assemblies:assemblies:noarch \
	$pkgname-reference-assemblies-2.0:assemblies20:noarch \
	$pkgname-reference-assemblies-3.5:assemblies35:noarch \
	$pkgname-reference-assemblies-4.0:assemblies40:noarch \
	$pkgname-reference-assemblies-4.x:assemblies4x:noarch \
"
source=" \
	http://download.mono-project.com/sources/mono/mono-${pkgver/_/~}.tar.bz2 \
	928eb4219f6527c23b5924d6e81fa5ba8660f0c4.patch::https://github.com/jaykrell/mono/commit/928eb4219f6527c23b5924d6e81fa5ba8660f0c4.patch \
	6462ec09a11119e36ea98925993f230b1c4eaa75.patch::https://github.com/mono/mono/commit/6462ec09a11119e36ea98925993f230b1c4eaa75.patch \
"
install="ca-certificates-$pkgname.post-deinstall"
builddir="$srcdir/$pkgname-$pkgver"

prepare() {
	default_prepare
	cd "$builddir"

	# Remove hardcoded lib directory from the config.
	sed -i 's|$mono_libdir/||g' data/config.in

	# We need to do this so it don't get killed in the build proces when
	# MPROTECT and RANDMMAP is enable.
	sed -i '/exec "/ i\paxmark mr "$(readlink -f "$MONO_EXECUTABLE")"' \
		runtime/mono-wrapper.in
}

build() {
	cd "$builddir"

	# Based on Fedora and SUSE package.
	export CFLAGS="$CFLAGS -fno-strict-aliasing"

	# Set the minimum arch for x86 to prevent atomic linker errors.
	[ "$CARCH" = "x86" ] && export CFLAGS="$CFLAGS -march=i586 -mtune=generic"

	# Run autogen to fix supplied configure linker issues with make install.
	./autogen.sh \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--disable-dependency-tracking \
		--disable-system-aot \
		--disable-rpath \
		--disable-boehm \
		--enable-parallel-mark \
		--with-x=no \
		--with-libgc=none \
		--with-mcs-docs=no \
		--with-ikvm-native=no

	make -j$(nproc)
}

package() {
	cd "$builddir"
	make -j1 DESTDIR="$pkgdir" install

	cd "$pkgdir"

	paxmark mr ./usr/bin/mono-sgen

	# Remove .la files.
	rm ./usr/lib/*.la

	# Remove Windows-only stuff.
	rm -rf	usr/lib/mono/*/Mono.Security.Win32*
}

runtime() {
	pkgdesc="Mono SGen runtime"
	depends="$pkgname-corlib"

	mkdir -p "$subpkgdir"/usr/bin \
			 "$subpkgdir"/usr/lib \
			 "$subpkgdir"/etc/mono \
			 "$subpkgdir"/usr/share/mono-2.0/mono

	mv	"$pkgdir"/etc/mono/config \
		"$pkgdir"/etc/mono/mconfig \
		"$pkgdir"/etc/mono/browscap.ini \
		"$pkgdir"/etc/mono/2.0 \
		"$pkgdir"/etc/mono/4.0 \
		"$pkgdir"/etc/mono/4.5 \
		"$subpkgdir"/etc/mono
	mv	"$pkgdir"/usr/bin/mono \
		"$pkgdir"/usr/bin/mono-sgen \
		"$subpkgdir"/usr/bin
	mv	"$pkgdir"/usr/lib/libMonoSupportW.* \
		"$pkgdir"/usr/lib/libMonoPosixHelper.so \
		"$pkgdir"/usr/lib/libmono-btls-shared.so \
		"$subpkgdir"/usr/lib
	mv	"$pkgdir"/usr/share/mono-2.0/mono/cil \
		"$subpkgdir"/usr/share/mono-2.0/mono
}

runtime_doc() {
	pkgdesc="Mono runtime documentation"
	depends="$pkgname-runtime"

	for manpage in \
		usr/share/man/man1/mono.1 \
		usr/share/man/man5/mono-config.5
	do
		mkdir -p "$(dirname "$subpkgdir/$manpage")"
		gzip -9 < "$pkgdir/$manpage" > "$subpkgdir/$manpage".gz
		rm "$pkgdir/$manpage"
	done
}

cacerts() {
	pkgdesc="Mono CA certificates sync utility"
	depends="$pkgname-runtime ca-certificates"

	mkdir -p "$subpkgdir"/usr/bin "$subpkgdir"/usr/lib/mono/4.5
	mv "$pkgdir"/usr/bin/cert-sync "$subpkgdir"/usr/bin
	mv "$pkgdir"/usr/lib/mono/4.5/cert-sync.exe "$subpkgdir"/usr/lib/mono/4.5

	mkdir -p "$subpkgdir"/etc/ca-certificates/update.d
	cat > "$subpkgdir"/etc/ca-certificates/update.d/ca-certificates-mono <<-EOF
	#!/bin/sh
	exec cert-sync /etc/ssl/certs/ca-certificates.crt
	EOF
	chmod +x "$subpkgdir"/etc/ca-certificates/update.d/ca-certificates-mono
}

cacerts_doc() {
	pkgdesc="Mono CA certificates sync utility documentation"

	for manpage in \
		usr/share/man/man1/cert-sync.1
	do
		mkdir -p "$(dirname "$subpkgdir/$manpage")"
		gzip -9 < "$pkgdir/$manpage" > "$subpkgdir/$manpage".gz
		rm "$pkgdir/$manpage"
	done
}

dev() {
	pkgdesc="Mono runtime development files and utilities"
	depends="$pkgname-runtime"

	default_dev

	mkdir -p "$subpkgdir"/usr/bin "$subpkgdir"/usr/lib/mono/4.5
	for bin in al caspol cccheck ccrewrite cert2spc certmgr chktrust crlupdate csharp disco dtd2rng dtd2xsd genxs httpcfg ikdasm ilasm illinkanalyzer installvst lc macpack makecert mconfig mcs mdbrebase mdoc mkbundle mod mono-api-html mono-api-info mono-cil-strip monolinker monop mono-service mono-shlib-cop mono-symbolicate mono-xmltool mozroots nunit-console pdb2mdb permview resgen secutil setreg sgen signcode sn soapsuds sqlmetal sqlsharp svcutil vbc wsdl xbuild xsd; do
		mv	"$pkgdir"/usr/bin/${bin} "$subpkgdir"/usr/bin
		mv	"$pkgdir"/usr/lib/mono/4.5/${bin}.exe "$subpkgdir"/usr/lib/mono/4.5
	done
}

corlib() {
	pkgdesc="Mono 4.5 mscorlib.dll"

	mkdir -p "$subpkgdir"/usr/lib/mono/4.5
	mv	"$pkgdir"/usr/lib/mono/4.5/mscorlib.dll \
		"$subpkgdir"/usr/lib/mono/4.5/
}

assemblies() {
	pkgdesc="Mono 4.5 reference assemblies"
	depends="$pkgname-runtime"

	mkdir -p "$subpkgdir"/usr/lib/mono/4.5 "$subpkgdir"/usr/lib/mono/gac
	mv	"$pkgdir"/usr/lib/mono/4.5/gacutil.exe \
		"$subpkgdir"/usr/lib/mono/4.5/

	for asm in \
		Accessibility \
		Commons.Xml.Relaxng \
		cscompmgd \
		CustomMarshalers \
		I18N.CJK \
		I18N \
		I18N.MidEast \
		I18N.Other \
		I18N.Rare \
		I18N.West \
		IBM.Data.DB2 \
		ICSharpCode.SharpZipLib \
		Microsoft.CSharp \
		Microsoft.VisualC \
		Microsoft.Web.Infrastructure \
		Mono.Btls.Interface \
		Mono.Cairo \
		Mono.CodeContracts \
		Mono.CompilerServices.SymbolWriter \
		Mono.CSharp \
		Mono.Data.Sqlite \
		Mono.Data.Tds \
		Mono.Debugger.Soft \
		Mono.Http \
		Mono.Management \
		Mono.Messaging \
		Mono.Messaging.RabbitMQ \
		Mono.Parallel \
		Mono.Posix \
		Mono.Profiler.Log \
		Mono.Security \
		Mono.Simd \
		Mono.Tasklets \
		Mono.WebBrowser \
		Novell.Directory.Ldap \
		nunit-console-runner \
		nunit.core \
		nunit.core.extensions \
		nunit.core.interfaces \
		nunit.framework \
		nunit.framework.extensions \
		nunit.mocks \
		nunit.util \
		PEAPI \
		RabbitMQ.Client \
		SMDiagnostics \
		System.ComponentModel.Composition \
		System.ComponentModel.DataAnnotations \
		System.Configuration \
		System.Configuration.Install \
		System.Core \
		System.Data.DataSetExtensions \
		System.Data \
		System.Data.Entity \
		System.Data.Linq \
		System.Data.OracleClient \
		System.Data.Services.Client \
		System.Data.Services \
		System.Deployment \
		System.Design \
		System.DirectoryServices \
		System.DirectoryServices.Protocols \
		System \
		System.Drawing.Design \
		System.Drawing \
		System.Dynamic \
		System.EnterpriseServices \
		System.IdentityModel \
		System.IdentityModel.Selectors \
		System.IO.Compression \
		System.IO.Compression.FileSystem \
		System.Json \
		System.Json.Microsoft \
		System.Management \
		System.Messaging \
		System.Net \
		System.Net.Http \
		System.Net.Http.Formatting \
		System.Net.Http.WebRequest \
		System.Numerics \
		System.Numerics.Vectors \
		System.Reactive.Core \
		System.Reactive.Debugger \
		System.Reactive.Experimental \
		System.Reactive.Interfaces \
		System.Reactive.Linq \
		System.Reactive.Observable.Aliases \
		System.Reactive.PlatformServices \
		System.Reactive.Providers \
		System.Reactive.Runtime.Remoting \
		System.Reactive.Windows.Forms \
		System.Reactive.Windows.Threading \
		System.Reflection.Context \
		System.Runtime.Caching \
		System.Runtime.DurableInstancing \
		System.Runtime.Remoting \
		System.Runtime.Serialization \
		System.Runtime.Serialization.Formatters.Soap \
		System.Security \
		System.ServiceModel.Activation \
		System.ServiceModel.Discovery \
		System.ServiceModel \
		System.ServiceModel.Internals \
		System.ServiceModel.Routing \
		System.ServiceModel.Web \
		System.ServiceProcess \
		System.Threading.Tasks.Dataflow \
		System.Transactions \
		System.Web.Abstractions \
		System.Web.ApplicationServices \
		System.Web \
		System.Web.DynamicData \
		System.Web.Extensions.Design \
		System.Web.Extensions \
		System.Web.Http \
		System.Web.Http.SelfHost \
		System.Web.Http.WebHost \
		System.Web.Mobile \
		System.Web.Mvc \
		System.Web.Razor \
		System.Web.RegularExpressions \
		System.Web.Routing \
		System.Web.Services \
		System.Web.WebPages.Deployment \
		System.Web.WebPages \
		System.Web.WebPages.Razor \
		System.Windows \
		System.Windows.Forms.DataVisualization \
		System.Windows.Forms \
		System.Workflow.Activities \
		System.Workflow.ComponentModel \
		System.Workflow.Runtime \
		System.Xaml \
		System.Xml \
		System.Xml.Linq \
		System.Xml.Serialization \
		WebMatrix.Data \
		WindowsBase
	do
		mv	"$pkgdir"/usr/lib/mono/4.5/${asm}.dll "$subpkgdir"/usr/lib/mono/4.5/
		mv	"$pkgdir"/usr/lib/mono/gac/${asm} "$subpkgdir"/usr/lib/mono/gac/
	done

}
assembliesapi() {
	pkgdesc="Mono 4.5 api reference assemblies"
	depends="$pkgname-runtime $pkgname-reference-assemblies"

	mkdir -p "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/4.5-api \
		"$subpkgdir"/usr/lib/mono/
}
assembliesfacades() {
	pkgdesc="Mono 4.5 reference assemblies facades"
	depends="$pkgname-runtime"

	mkdir -p "$subpkgdir"/usr/lib/mono/4.5
	mv	"$pkgdir"/usr/lib/mono/4.5/Facades \
		"$subpkgdir"/usr/lib/mono/4.5
}

assemblies20() {
	pkgdesc="Mono 2.0 reference assemblies"
	depends="$pkgname-runtime"

	mkdir -p "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/2.0-api "$subpkgdir"/usr/lib/mono/
}
assemblies35() {
	pkgdesc="Mono 3.5 reference assemblies"
	depends="$pkgname-runtime $pkgname-reference-assemblies-2.0"

	mkdir -p "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/3.5-api "$subpkgdir"/usr/lib/mono/
}
assemblies40() {
	pkgdesc="Mono 4.0 reference assemblies"
	depends="$pkgname-runtime"

	mkdir -p "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/4.0 \
		"$pkgdir"/usr/lib/mono/4.0-api \
		"$subpkgdir"/usr/lib/mono/
}

assemblies4x() {
	pkgdesc="Mono 4.x reference assemblies"
	depends="$pkgname-runtime $pkgname-reference-assemblies"

	mkdir -p "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/4.*-api "$subpkgdir"/usr/lib/mono/
}

libmono() {
	pkgdesc="Shared library for Mono runtime"

	install -d "$subpkgdir"/usr/lib
	mv	"$pkgdir"/usr/lib/libmono-2.0.so* \
		"$pkgdir"/usr/lib/libmonosgen-2.0.so* \
		"$subpkgdir"/usr/lib
}

utils() {
	pkgdesc="Common utilities for Mono runtime"
	#depends="$subpkgname-doc"

	install -d "$subpkgdir"/usr/bin
	mv	"$pkgdir"/usr/bin/mono-find-provides \
		"$pkgdir"/usr/bin/mono-find-requires \
		"$pkgdir"/usr/bin/peverify \
		"$subpkgdir"/usr/bin
		#
		#"$pkgdir"/usr/bin/monodis \
		#"$pkgdir"/usr/bin/mprof-report \
		#"$pkgdir"/usr/bin/pedump \
}

csc() {
	pkgdesc="Mono C# compiler (csc/csc-dim)"
	depends="$pkgname-runtime $pkgname-reference-assemblies $pkgname-reference-assemblies-facades"

	mkdir -p "$subpkgdir"/usr/lib/mono/4.5 "$subpkgdir"/usr/bin
	mv	"$pkgdir"/usr/lib/mono/4.5/csc.exe \
		"$pkgdir"/usr/lib/mono/4.5/csc.exe.config \
		"$pkgdir"/usr/lib/mono/4.5/csc.rsp \
		"$pkgdir"/usr/lib/mono/4.5/csi.exe \
		"$pkgdir"/usr/lib/mono/4.5/csi.exe.config \
		"$pkgdir"/usr/lib/mono/4.5/csi.rsp \
		"$pkgdir"/usr/lib/mono/4.5/dim \
		"$pkgdir"/usr/lib/mono/4.5/System.Collections.Immutable.dll \
		"$pkgdir"/usr/lib/mono/4.5/System.Reflection.Metadata.dll \
		"$pkgdir"/usr/lib/mono/4.5/Microsoft.CodeAnalysis.dll \
		"$pkgdir"/usr/lib/mono/4.5/Microsoft.CodeAnalysis.Scripting.dll \
		"$pkgdir"/usr/lib/mono/4.5/Microsoft.CodeAnalysis.CSharp.dll \
		"$pkgdir"/usr/lib/mono/4.5/Microsoft.CodeAnalysis.CSharp.Scripting.dll \
		"$subpkgdir"/usr/lib/mono/4.5
	mv	"$pkgdir"/usr/bin/csc \
		"$pkgdir"/usr/bin/csi \
		"$pkgdir"/usr/bin/csc-dim \
		"$pkgdir"/usr/bin/gacutil \
		"$pkgdir"/usr/bin/gacutil2 \
		"$subpkgdir"/usr/bin
}

xbuild() {
	pkgdesc="xbuild build system for Mono runtime"
	depends="$pkgname-runtime $pkgname-reference-assemblies $pkgname-csc"

	mkdir -p "$subpkgdir"/usr/lib/mono/gac "$subpkgdir"/usr/lib/mono/4.5
	mv	"$pkgdir"/usr/lib/mono/monodoc \
		"$pkgdir"/usr/lib/mono/msbuild \
		"$pkgdir"/usr/lib/mono/xbuild \
		"$pkgdir"/usr/lib/mono/xbuild-frameworks \
		"$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/4.5/Microsoft.Build* \
		"$pkgdir"/usr/lib/mono/4.5/Mono.XBuild.Tasks* \
		"$pkgdir"/usr/lib/mono/4.5/MSBuild \
		"$pkgdir"/usr/lib/mono/4.5/*.targets \
		"$pkgdir"/usr/lib/mono/4.5/*.tasks \
		"$subpkgdir"/usr/lib/mono/4.5
	mv	"$pkgdir"/usr/lib/mono/gac/Microsoft.Build* \
		"$pkgdir"/usr/lib/mono/gac/Mono.XBuild.Tasks* \
		"$subpkgdir"/usr/lib/mono/gac
}

dbg() {
	default_dbg
	depends="$pkgname"

	mkdir -p "$subpkgdir"/usr/bin "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/lib/mono/lldb "$subpkgdir"/usr/lib/mono
	mv	"$pkgdir"/usr/bin/mono*-gdb.py "$subpkgdir"/usr/lib/debug/usr/bin/

	local file
	find "$pkgdir" \( -name '*.pdb' -o -name '*.mdb' \) | while read file; do
		local destfile="$(echo "$file" | sed "s|$pkgdir|$subpkgdir|")"
		mkdir -p "$(dirname "$destfile")"
		mv	"$file" "$destfile"
	done
}

sha512sums="f13afbe4289e177705642f79f4236710bdc8db8e956782c5370baf22207d6713f7997ec286c7742416c8206d2da205f295437d1afcdc430628d13e32f0e87d2d  mono-5.14.0.177.tar.bz2
7d3da02ff6258e488904fbfb737d8cad0b652dfdd076781fa7722bcd14b0163f4783651c96d4de31815b64df3cfed4927c9df8b71dfb0bb4d6acd8b1331cc995  928eb4219f6527c23b5924d6e81fa5ba8660f0c4.patch
2d669bec0dd5e6b414c049bcefd8d4dcf1a032475d51b8f2b408928f5f7f9c61780153e3609f4c2542abbe9d514fab0da55fc901f02c41e4f1c2a0b9daa60783  6462ec09a11119e36ea98925993f230b1c4eaa75.patch"

# vim: ft=sh noet
