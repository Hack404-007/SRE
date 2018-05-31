#!/bin/bash
#
# Name: mkscrip
# Description: Create script
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 16/01/2016 14:20:00
# Usage: Mkscript FileName

while getopts ":d:" OPT; do
	case "$OPT" in
	d)
		DESC=$OPTARG ;;
	\?)
		echo "Usage: mkscript [-d DESCRIPTIONS ] FILENAME";;
	esac
done

shift $[$OPTIND-1]
if ! grep "[^[:space:]]" $1 &> /dev/null; then
cat > $1 <<EOF
#!/bin/bash
#
# Name:`basename $1`
# Description: $DESC
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: `date +"%F %T"`
# Usage: `basename $1`

EOF
fi
vim + $1

until bash -n $1 &> /dev/null; do
	read -p "Syntax error, q|Q for quiting, others for edit:" OPT
	case "$OPT" in
		q|Q)
		echo "Quit."
		exit 8 ;;
		*)
		vim + $1
	esac
done
chmod +x $1
