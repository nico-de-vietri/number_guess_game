#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# generate random number
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 )) 
echo "Enter your username:"
read USER_NAME

# query get username
YUSER_NAME=$($PSQL "SELECT username FROM users WHERE username='$USER_NAME'")

if [[ $YUSER_NAME ]]
 then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER_NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER_NAME'")  
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
 else
   echo "Welcome, $USER_NAME! It looks like this is your first time here."
   INSERT_NAME=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
fi   

echo "Guess the secret number between 1 and 1000:"

i=1
while read INPUT
    do
      if [[ ! $INPUT =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else  
        # if user guesses then update DB table and exit the programm 
        if [[ $INPUT -eq $SECRET_NUMBER ]] 
        then
          TRIES=$i
          echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
          UPDATE_USERS_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED+1)) WHERE username='$USER_NAME'")
          BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER_NAME'")
          if [[ -z $BEST_GAME ]] 
          then
            UPDATE_USERS_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username='$USER_NAME'")
            else
            if [[ $TRIES -lt $BEST_GAME ]]
            then
              UPDATE_USERS_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username='$USER_NAME'")
            fi
          fi    
        exit
        else
          if [[ $INPUT -gt $SECRET_NUMBER ]]
          then
            echo "It's lower than that, guess again:" 
            ((i+=1))
          else
            if [[ $INPUT -lt $SECRET_NUMBER ]]
            then
              echo "It's higher than that, guess again:"
              ((i+=1))            
            fi  
          fi
        fi
      fi         
    done    
