#!/bin/sh

case "`echo -e`" in
  -e)
    ECHO() { echo "$@"; }
    ;;
  *)
    ECHO() { echo -e "$@"; }
    ;;
esac

case "`ECHO '\r'`" in
  '\r')
    case "`(print X) 2> /dev/null`" in
      X)
        ECHO() { print "$@"; }
        ;;
      *)
        PATH=/usr/5bin:$PATH
        export PATH
        ;;
    esac
    ;;
esac

case "$((1))" in
  1)
    expr()
    {
      echo "$(($*))"
    }
    ;;
esac 2> /dev/null

cls()
{
  ECHO '\033[H\033[2J\c'
}

cursor()
{
  ECHO '\033['$2';'$1'H\c'
}

beep()
{
  ECHO '\07\c'
}

new_screen()
{
  ECHO '\033\067\033[?47h\c'
}

exit_screen()
{
  ECHO '\033[?47l\033\070\c'
}

init_tty()
{
  stty -icanon -echo min 1 -ixon
  new_screen
  cls
}

quit_tty()
{
  cls
  exit_screen
  stty icanon echo eof '^d' ixon
}

getchar()
{
  dd bs=1 count=1 2> /dev/null
}

# trap

if (trap '' INT) 2> /dev/null
then
  SIGINT=INT SIGQUIT=QUIT SIGTERM=TERM SIGTSTP=TSTP
else
  SIGINT=2 SIGQUIT=3 SIGTERM=15 SIGTSTP=18
fi

# program

init_map()
{
  cursor 1 1
  ECHO \
'┏━━━━━━━━━━━━━━━━━━━'\
'━━━━━━━━━━━━━━━━━━━┓\c'
  i=2
  while [ $i -le 30 ]; do
    cursor 1 $i
    ECHO \
'┃                                      '\
'                                      ┃\c'
    i=`expr $i + 1`
  done
  cursor 1 31
  ECHO \
'┗━━━━━━━━━━━━━━━━━━━'\
'━━━━━━━━━━━━━━━━━━━┛\c'
}

clear_line()
{
  cursor 3 $1
  ECHO \
'                                      '\
'                                      \c'
}

print_line()
{
  if [ `expr $1 + $2 - 1` -gt 78 ]; then
    NUM=`expr $1 + $2`
    NUM=`expr $NUM - 80`
    NUM=`expr $NUM + 1`
    NUM=`expr $NUM / 2`

    TMP_AA1=`echo $3 | sed -e "s/^.*\(.\{$NUM\}$\)/\1/"`
    TMP_AA2=`echo $3 | sed -e "s/\(^.*\).\{$NUM\}$/\1/"`

    cursor 3 16
    ECHO "$TMP_AA1\c"

    cursor $1 16
    ECHO "$TMP_AA2\c"
  else
    cursor $1 16
    ECHO "$3\c"
  fi
}

debug_print()
{
  clear_line $1
  cursor 1 $1
  ECHO $2
}

# main

trap '' $SIGINT $SIGQUIT $SIGTSTP
trap : $SIGTERM

AA1="（」・ω・）」うー！"
AA2="（／・ω・）／にゃー！"
AA3="Let's＼（・ω・）／にゃー！"
AA1_LEN=20
AA2_LEN=22
AA3_LEN=32
AA_TYPE=1

INIT_X=3
X=$INIT_X
Y=16

COUNT=1

TIME1=0.85
TIME2=2

init_tty
init_map

(
  COUNT1=1
  TIME=$TIME1

  while :
  do
    sleep $TIME
    ECHO '~\c'

    if [ $COUNT1 -eq 6 ]; then
      TIME=$TIME2
      COUNT1=0
    else
      TIME=$TIME1
      COUNT1=`expr $COUNT1 + 1`
    fi


  done &
  /bin/cat
) | while :
do
  key=`getchar`
  case "$key" in
    '~')
      clear_line $Y
      cursor $X $Y
      case "$AA_TYPE" in
        1)
          print_line $X $AA1_LEN $AA1
          AA_TYPE=2
          ;;
        2)
          print_line $X $AA2_LEN $AA2
          AA_TYPE=1
          ;;
        3)
          print_line 27 $AA3_LEN $AA3
          AA_TYPE=1
          ;;
      esac

      if [ $COUNT -eq 6 ]; then
        AA_TYPE=3
        COUNT=0
      else
        COUNT=`expr $COUNT + 1`
        X=`expr $X + 2`
      fi

      if [ $X -gt 78 ]; then
        X=$INIT_X
      fi

      ;;
    q)
      kill -TERM 0
      break
      ;;
  esac
done

quit_tty
exit
