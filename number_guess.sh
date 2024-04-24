#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# promp users player for username
echo -e "\nEnter your username:"
read USERNAME

# get username data
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if player is not found
if [[ -z $USERNAME_RESULT ]]
  then
    # greet player
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    # add player to database
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    
  else
    
    USERNAME=$(echo $($PSQL "SELECT username FROM users WHERE username='$USERNAME';") | sed 's/ //g')
    USER_ID=$(echo $($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';") | sed 's/ //g') 
    GAMES_PLAYED=$(echo $($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME';") | sed 's/ //g')
    BEST_GAME=$(echo $($PSQL "SELECT MIN(n_guessed) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME';") | sed 's/ //g')

    echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# variable to store number of guesses/tries
FRECUENT_GAMES=0

# prompt first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS


# loop to prompt user to guess until correct
until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  
  # check guess is valid/an integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      # request valid guess
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS
      # update guess count
      ((FRECUENT_GAMES++))
    
    # if its a valid guess
    else
      # check inequalities and give hint
      if [[ $USER_GUESS < $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read USER_GUESS
          # update guess count
          ((FRECUENT_GAMES++))
        else 
          echo "It's lower than that, guess again:"
          read USER_GUESS
          #update guess count
          ((FRECUENT_GAMES++))
      fi  
  fi

done

# loop ends when guess is correct so, update guess
((FRECUENT_GAMES++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
# add result to game history/database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, n_guessed) VALUES ($USER_ID_RESULT, $FRECUENT_GAMES)")

# winning message
echo You guessed it in $FRECUENT_GAMES tries. The secret number was $SECRET_NUMBER. Nice job\!