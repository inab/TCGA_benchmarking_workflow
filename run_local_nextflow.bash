#!/bin/bash

NEXTFLOW_VER=19.10.0

JDK_MAJOR_VER=11
JDK_VER=${JDK_MAJOR_VER}.0.11
JDK_REV=9
JDK_ARCH=x64_linux
OPENJ9_VER=0.26.0

set -e

scriptdir="$(dirname "$0")"

case "$scriptdir" in
	/*)
		true
		;;
	.)
		scriptdir="$(pwd)"
		;;
	*)
		scriptdir="$(realpath "${scriptdir}")"
		;;
esac

declare downloadDir

cleanup() {
	if [ -n "${downloadDir}" ] ; then
		rm -rf "${downloadDir}"
	fi
}

trap cleanup EXIT ERR


setup_java() {
	local javainstalldir="$1/java"
	if [ -d "$javainstalldir" ] ; then
		NXF_JAVA_HOME="${javainstalldir}"
		export NXF_JAVA_HOME
	fi
	if [ -n "$NXF_JAVA_HOME" ] ; then
		JAVA_HOME="$ŃXF_JAVA_HOME"
		export JAVA_HOME
		PATH="${NXF_JAVA_HOME}/bin:${PATH}"
		export PATH
	fi
	local java_ver="$(java -version 2>&1 | grep -F version | cut -f 2 -d '"')"

	local do_install_java
	if [ "$java_ver" = "" ] ; then
		do_install_java=1
	else
		local java_major_ver="${java_ver%%.*}"
		if [ "$java_major_ver" -ge 15 ] ; then
			do_install_java=1
		elif [ "$java_major_ver" -lt 8 ] ; then
			do_install_java=1
		fi
	fi

	if [ -n "$do_install_java" ] ; then
		downloadDir="$(mktemp -d --tmpdir java_installer.XXXXXXXXXXX)"
		echo "${downloadDir} will be used to download third party dependencies, and later removed"

		local OPENJDK_URL="https://github.com/AdoptOpenJDK/openjdk${JDK_MAJOR_VER}-binaries/releases/download/jdk-${JDK_VER}%2B${JDK_REV}_openj9-${OPENJ9_VER}/OpenJDK${JDK_MAJOR_VER}U-jdk_${JDK_ARCH}_openj9_${JDK_VER}_${JDK_REV}_openj9-${OPENJ9_VER}.tar.gz"
		wget -nv -P "$downloadDir" "$OPENJDK_URL"
		mkdir -p "${javainstalldir}"
		NXF_JAVA_HOME="${javainstalldir}"
		export NXF_JAVA_HOME
		JAVA_HOME="$ŃXF_JAVA_HOME"
		export JAVA_HOME
		PATH="${NXF_JAVA_HOME}/bin:${PATH}"
		export PATH
		tar -x -C "${javainstalldir}" -f "${downloadDir}"/OpenJDK*.tar.gz
		mv "${javainstalldir}"/jdk*/* "${javainstalldir}"
		rm -rf "${javainstalldir}"/jdk*
	fi
}

setup_nextflow() {
	local NEXTFLOW_VER="$1"
	local basenextdir="$2"
	local destdir="${basenextdir}/${NEXTFLOW_VER}"

	destfile="${destdir}/nextflow"
	
	if [ ! -f "$destfile" ] ; then
		mkdir -p "$destdir"
		wget -nv -O "$destfile" "https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VER}/nextflow"
	fi

	if [ ! -x "$destfile" ] ; then
		chmod +x "$destfile"
	fi

	# These are global envvars
	NXF_HOME="${destdir}/.nextflow"
	export NXF_HOME
	NXF_WORKDIR="${basedestdir}/workdir"
	export NXF_WORKDIR
	NXF_ASSETS="${destdir}/assets"
	export NXF_ASSETS
	PATH="${destdir}:${PATH}"
	export PATH
	
	# Getting all working
	if [ ! -d "${NXF_HOME}" ] ; then
		nextflow -download
	fi
}

cd "$scriptdir"

nextflow_install_dir="${scriptdir}/nextflow_install_dir"
setup_java "${nextflow_install_dir}"
setup_nextflow "$NEXTFLOW_VER" "${nextflow_install_dir}"

exec nextflow "$@"
