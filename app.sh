#!/bin/bash

####################
#    VARIABLES     #
####################

DICTIONARY="dictionary.txt"
COUNT=$(wc -l $DICTIONARY | xargs | cut -d ' ' -f 1) # get amount words from dictionary
YELLOW='\033[0;33m' # Yellow
GREEN='\033[0;32m'  # Green
RED="\033[0;31m"    # Red
NC="\033[0m"        # No Color
#old_ifs="$IFS"
IFS=","
correct=0; wrong=0

####################
#    FUNCTIONS     #
####################

# function of menu
FUNCTION_MENU_TEXT () {
  echo "To EXIT write \"exit\"

1)Learn words
2)Russian words
3)English words
4)Add new word to dictionary
5)Remove word from dictionary
"
}

# function amount correct words
FUNCTION_COUNTER () {
  if [ "" = "$1" ] && [ "" = "$2" ]
    then echo -e "${GREEN}#${correct}${NC}  ${RED}#${wrong}${NC}"
  else
    correct=$(( correct + $1 ))
    wrong=$(( wrong + $2 ))
  fi
}

# function text of return
FUNCTION_RETURN_TEXT () {
  echo -e "To return in menu, write 'exit'\n"
}

# exit function
FUNCTION_ESCAPE () {
  if [ "$enterWord" = 'exit' ] || [ "$enterWord" = 'учше' ]
    then
      correct=0; wrong=0
      sleep 0.2; break
  fi
}

# function get random word
FUNCTION_RUNDOM_WORD () {
  listOfRuWords=(); listOfEnWords=()  # define list to words
  randomCount="$(( 1 + RANDOM%COUNT ))p"
  getString=$(sed -n $randomCount $DICTIONARY)
  getRuWords=$(cut -d ':' -f 1 <<< "${getString}")
  getEnWords=$(cut -d ':' -f 2 <<< "${getString}")
  sentence=$(cut -d ':' -f 3 <<< "${getString}")
  for i in $getRuWords; do listOfRuWords+=("${i}"); done
  for i in $getEnWords; do listOfEnWords+=("${i}"); done
  ruWord=${listOfRuWords[$(( $(( 1 + RANDOM%${#listOfRuWords[@]} )) - 1 )) ]}
  enWord=${listOfEnWords[$(( $(( 1 + RANDOM%${#listOfEnWords[@]} )) - 1 )) ]}
}

# function echo learn words
FUNCTION_LEARN_WORD () {
  while true
  do
    FUNCTION_RUNDOM_WORD # get random words
    clear
    FUNCTION_RETURN_TEXT
    echo "$enWord = $ruWord"
    read enterWord
    FUNCTION_ESCAPE
  done
}

# function echo russian words
FUNCTION_RUS_WORD () {
  while true
  do
    FUNCTION_RUNDOM_WORD # get random words
    clear
    FUNCTION_RETURN_TEXT
    FUNCTION_COUNTER
#    echo ${sentence}
    echo -e "Введите перевод слова: ${YELLOW}$ruWord${NC}"
    read enterWord
    FUNCTION_ESCAPE
    if [[ "${getEnWords[*]}" =~ $enterWord ]]
      then
        echo -e "${GREEN}Верно!${NC}"
        FUNCTION_COUNTER 1 0 # 1 score for correct words
        sleep 0.7
      else
        echo -e "${RED}Неверно! ¯\_(ツ)_/¯${NC}"
        echo -e "${RED}Правильное слово:${NC} ${getEnWords[*]}"
        FUNCTION_COUNTER 0 1 # 1 score for wrong words
        read empty
    fi
  done
}

# function echo english word
FUNCTION_EN_WORD () {
  while true
  do
    FUNCTION_RUNDOM_WORD # get random words
    clear
    FUNCTION_RETURN_TEXT
    FUNCTION_COUNTER
    echo ${sentence}
    echo -e "Write translation: ${YELLOW}$enWord${NC}"
    read -r enterWord
    FUNCTION_ESCAPE
    if [[ "${getRuWords[*]}" =~ $enterWord ]]
      then
        echo -e "${GREEN}Right!${NC}"
        FUNCTION_COUNTER 1 0 # 1 score for correct words
        sleep 0.7
      else
        echo -e "${RED}Wrong! ¯\_(ツ)_/¯${NC}"
        echo -e "${RED}Correct word:${NC} ${getRuWords[*]}"
        FUNCTION_COUNTER 0 1 # 1 score for wrong words
        read empty
    fi
  done
}


# script new word in dictionary
FUNCTION_ADD_NEW_WORD () {
  clear
  if [ ! -f $DICTIONARY ]
    then
      touch $DICTIONARY
  fi
    echo -n "Word in Russian: "; read -r ruWord
    echo -n "Word in English: "; read -r enWord
    echo "$ruWord:$enWord" >> $DICTIONARY
    COUNT=$(wc -l $DICTIONARY | xargs | cut -d ' ' -f 1)
    echo "The word is added to the dictionary!"
    sleep 1
}

# script delete word from dictionary
FUNCTION_DELETE_WORD () {
  clear
  if [ ! -f $DICTIONARY ]
    then
      echo -e "\nThe dictionary does not exist. Create a dictionary\n"
      sleep 2
      return
  fi
    echo -n "Word to delete: "; read WORD_TO_DELETE
    sed -i '' "/$WORD_TO_DELETE/d" $DICTIONARY
    COUNT=$(wc -l $DICTIONARY | xargs | cut -d ' ' -f 1)
    echo "Word removed from dictionary!"
    sleep 1
}

####################
#   START SCRIPT   #
####################

clear
echo "---WELCOME!---"

while true
do
  clear
  FUNCTION_MENU_TEXT # function of menu
  echo -n "Select item: "; read -r select
  case "$select" in
    1) FUNCTION_LEARN_WORD
       ;;
    2) FUNCTION_RUS_WORD
       ;;
    3) FUNCTION_EN_WORD
       ;;
    4) FUNCTION_ADD_NEW_WORD
       ;;
    5) FUNCTION_DELETE_WORD
       ;;
    exit | учше) clear
       echo "Goodbye!"
       sleep 0.4
       exit 0
       ;;
  esac
done
exit 0
