#!/bin/bash
function help(){
echo "inodes - Count the amount of inodes in a given directory";
echo "Usage example:";
echo "inodes (-d|--dir) string [(-h|--help)] [(-t|--tree) integer] [(-e|--exclude) integer]";
echo "Options:";
echo "-h or --help: Displays this information.";
echo "-d or --dir string: Directory to scan and count inodes. Required.";
echo "-t or --tree integer: Show tree for directories with inodes above this number.";
echo "-e or --exclude integer: Exclude directory from report when below this many inodes.";
exit 1;
}
GET_SIZE(){
du -hs $1 |cut -f 1
}
GET_COUNT(){
find $1 |wc -l
}
SHOW_LINE(){
echo "------------------------------------------"
}
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
clear
ARGS=$(getopt -o "hd:t:e:" -l "help,dir:,tree:,exclude:" -n "inodes" -- "$@");
if [ $? -ne 0 ];
then
help;
fi
eval set -- "$ARGS";
while true; do
case "$1" in
-h|--help)
shift;
help;
;;
-d|--dir)
shift;
if [ -n "$1" ];
then
a5="$1";
SHOW_LINE
printf "[CONFIG] Directory to scan specified as $1\n"
shift;
fi
;;
-t|--tree)
shift;
if [ -n "$1" ];
then
a4="$1";
SHOW_LINE
printf "[CONFIG] Tree directories above $1 inodes\n"
shift;
fi
;;
-e|--exclude)
shift;
if [ -n "$1" ];
then
a1="$1";
SHOW_LINE
printf "[CONFIG] Exclude directories below $1 inodes\n"
shift;
fi
;;
--)
shift;
break;
;;
esac
done
if [[ -z "$a5" && -n $1 && $1 != -* ]]
then
SHOW_LINE
printf "${RED}[CONFIG] Arguments not used, directory specified as $1 $NORMAL \n"
CURDIR=$1;
elif [[ -z "$a5" || "$a5" == "." ]]
then
CURDIR=`pwd`;
SHOW_LINE
printf "${RED}[ERROR] dir not specified, or invalid arguments, using $CURDIR $NORMAL\n";
else
CURDIR="$a5";
fi
OLDIFS=$IFS
IFS=$'\n'
a2="%-10s | %-10s | %-20s\n"
a3="${REVERSE}%-10s | %-10s | %-20s\n${NORMAL}"
a0="${CYAN}%-10s | %-10s | %-20s\n${NORMAL}"
SHOW_LINE
printf "\tINODE USAGE SUMMARY\n"
SHOW_LINE
printf "$a3" "    INODES" "      SIZE" "DIRECTORY"
SHOW_LINE
for DIR in `find $CURDIR -maxdepth 1 -type d |grep -xv $CURDIR |sort`; do
COUNT=$(GET_COUNT $DIR)
SIZE=$(GET_SIZE $DIR)
if [[ -z $a1 ]] || [[ -n $a1 && $COUNT -gt $a1 ]]
then
printf "$a2" "  $COUNT" "  $SIZE" "`basename $DIR`"
fi
if [[ -n $a4 && $COUNT -gt $a4 ]]
then
for TREEDIR in `find $DIR -maxdepth 1 -type d |grep -xv $DIR |sort`; do
TREECOUNT=$(GET_COUNT $TREEDIR)
TREESIZE=$(GET_SIZE $TREEDIR)
if [[ -z $a1 ]] || [[ -n $a1 && $TREECOUNT -gt $a1 ]]
then
printf "$a0" "  --$TREECOUNT" "  --$TREESIZE" "--`basename $TREEDIR`"
fi
done
fi
done
SHOW_LINE
printf "$a3" "$(GET_COUNT $CURDIR)" "$(GET_SIZE $CURDIR)" "$CURDIR"
SHOW_LINE
IFS=$OLDIFS