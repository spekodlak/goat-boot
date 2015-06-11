#!/bin/bash
#
# Create a bootable UBCD ISO image
#
# Ultimate Boot CD (UBCD): http://www.ultimatebootcd.com/
# The Syslinux Project: http://syslinux.zytor.com
#
# Made by Gert Hulselmans
#
# Last time edited: 8 July 2009

# Define VOLUME_ID (LABEL) of the iso
VOLUME_ID="UBCD535"

# Define ISO filename (can be overridden by passing arguments to the script)
ISO_FILENAME="ubcd535-custom.iso"

echo
echo 'UBCD2ISO: Creating bootable UBCD ISO image ...'
echo

# Check how many arguments are passed to the script
case "${#@}" in
	0)
		ROOT_OF_ISO_PATH=`cd "$(dirname "$0")/../../../../"; echo "${PWD}"`
		ISO_FILENAME=`echo "${ROOT_OF_ISO_PATH%/*}/${ISO_FILENAME}"`

		echo '  USAGE: ubcd2iso.sh [path-to-extracted-UBCD-iso] [new-ubcd.iso]'
		echo
		echo '  Example: ubcd2iso.sh ~/ubcd-extracted/ ~/ubcd50-custom.iso'
		echo "             UBCD extracted to '~/ubcd-extracted/',"
		echo "             ISO image written to '~/ubcd50-custom.iso'"
		echo
		echo 'UBCD2ISO: No arguments are given, use default values.'
		echo
		;;
	1)
		if [ "${1:0:1}" == '~' ]; then
			ROOT_OF_ISO_PATH="`echo ~`"${1:1}""
		else
			ROOT_OF_ISO_PATH="$1"
		fi

		if [ -d "$ROOT_OF_ISO_PATH" ]; then
			ROOT_OF_ISO_PATH=`cd "$ROOT_OF_ISO_PATH"; echo "${PWD}"`
			ISO_FILENAME=`echo "${ROOT_OF_ISO_PATH%/*}/${ISO_FILENAME}"`
		else
			ROOT_OF_ISO_PATH=''
			echo "UBCD2ISO ERROR: \"$1\" isn't a directory."
		fi
		;;
	2)
		if [ "${1:0:1}" == '~' ]; then
			ROOT_OF_ISO_PATH="`echo ~`"${1:1}""
		else
			ROOT_OF_ISO_PATH="$1"
		fi

		if [ -d "$ROOT_OF_ISO_PATH" ]; then
			ROOT_OF_ISO_PATH=`cd "$ROOT_OF_ISO_PATH"; echo "${PWD}"`
		else
			ROOT_OF_ISO_PATH=''
			echo "UBCD2ISO ERROR: \"$1\" isn't a directory."
		fi

		if [ "${2:0:1}" == '~' ]; then
			ISO_FILENAME="`echo ~`"${2:1}""
		else
			ISO_FILENAME="$2"
		fi

		if [ -d `cd "/${ISO_FILENAME%/*}" /dev/null 2>&1; echo "${PWD}"` ]; then
			ISO_FILENAME=`cd "/${ISO_FILENAME%/*}" /dev/null 2>&1; echo "${PWD}/${ISO_FILENAME##*/}"`
			ISO_FILENAME=`echo "${ISO_FILENAME/\/\///}"`
		else
			echo "UBCD2ISO ERROR: '${ISO_FILENAME%/*}' isn't a directory."
			echo "                '${ISO_FILENAME}' could not be created."
		fi
		;;
esac

# save IFS
SAVED_IFS=$IFS

# Poor man's 'which' command
MKISOFS=''
IFS=:
for i in $PATH ; do
	if [ -x "$i/mkisofs" ] ; then
		MKISOFS="$i/mkisofs"
		break
	fi
done

# Restore IFS
IFS=$SAVED_IFS

if [[ -n "$MKISOFS" && -n "$ROOT_OF_ISO_PATH" ]]; then
	if [ -f "${ROOT_OF_ISO_PATH}/boot/syslinux/isolinux.bin" ]; then
		rm -f "${ROOT_OF_ISO_PATH}/boot/syslinux/boot.catalog"
		rm -fR "${ROOT_OF_ISO_PATH}/[BOOT]/"
		rm -fR "${ROOT_OF_ISO_PATH}/boot.images/"

		# mkisofs manpage: http://linux.die.net/man/8/mkisofs
		#
		# -iso-level 4: Required for Win2K/XP booting to work
		# -l: Allow full 31 character ISO9660 filenames
        # -r: Rock Ridge Interchange Protocol allows Unix long filenames up to 255 bytes
		# -J -joliet-long: Joliet extension allows Windows long filenames up to 103 Unicode chars
		# -D: Disable deep directory relocation
		#
		# Note: UBCD2ISO_ARGS is used to pass user-specific arguments to mkisofs without modifying the script
		"$MKISOFS" -iso-level 4 -l -r -J -joliet-long -D -V "${VOLUME_ID}" \
		  -o "${ISO_FILENAME}" -b "boot/syslinux/isolinux.bin" -c "boot/syslinux/boot.catalog" \
		  -hide "boot/syslinux/boot.catalog" -hide-joliet "boot/syslinux/boot.catalog" \
		  $UBCD2ISO_ARGS -no-emul-boot -boot-load-size 4 -boot-info-table "${ROOT_OF_ISO_PATH}"
		if [ "$?" -eq "0" ]; then
			echo
			echo "UBCD2ISO: '${ISO_FILENAME}' was successfully created."
		else
			echo
			echo "UBCD2ISO ERROR: Something went wrong, while creating '${ISO_FILENAME}'".
		fi
	else
		echo "UBCD2ISO ERROR: '${ROOT_OF_ISO_PATH}/boot/syslinux/isolinux.bin' could not be found."
		echo '                Check that you have given the correct path to the extracted UBCD iso.'
	fi
elif [ -z "$MKISOFS" ]; then
	echo "UBCD2ISO ERROR: The 'mkisofs' program could not be found. Install it and try again."
fi

echo
