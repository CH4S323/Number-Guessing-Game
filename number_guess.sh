#!/bin/bash
secret_number=$(( 1 + $RANDOM % 1000 ))
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
number_of_guesses=0
GamePlayed=0

get(){
  echo "Guess the secret number between 1 and 1000:"
  read GuessNum
  if [[ $1 ]]
  then
    user=$1
  fi
  (( number_of_guesses++ ))
  #checking is a number
  if [[ $GuessNum =~ ^[0-9]+$ ]]
  #if it is
  then
    #Check higher
    if [[ $GuessNum -lt $secret_number ]]
    #Higher
    then
      echo "It's higher than that, guess again:"
      get $user
    #Check Lower
    elif [[ $GuessNum -gt $secret_number ]]
    #Lower
    then
      echo "It's lower than that, guess again:"
      get $user
    else
      (( GamePlayed++ ))
      if [[ -z $user ]]
      #for new player
      then
        # Insert new info
        Insert=$($PSQL "insert into played values('$username', $GamePlayed, $number_of_guesses)")
      #for old player
      else
        # update old info
        UpdateGame=$($PSQL "update played set game_played = $GamePlayed where username = '$UserName'")
        UpdateBest=$($PSQL "update played set best_game = $number_of_guesses where username = '$UserName' and best_game > $number_of_guesses")
      fi
      echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
    fi
  else
    echo "That is not an integer, guess again:"
    get $user
  fi
}

echo "Enter your username:"
read username
#check Name
GetName=$($PSQL "select * from played where username = '$username'")
IFS='|' read UserName games_played best_game <<< "$GetName"
# if not
if [[ -z $GetName ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  get
# if name
else
  echo "Welcome back, $UserName! You have played $games_played games, and your best game took $best_game guesses."
  get $UserName
fi
