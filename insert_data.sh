#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY;")
cat games.csv | while IFS="," read Y R W O W_G O_G
do
  
  if [[ $W != "winner" ]]
  then TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$W'")

    if [[ -z $TEAM_ID ]]
    then 
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$W')")
    TEAM_ID=$($PSQL "SELECT team_id from teams WHERE name='$W'")
    fi

    if [[ $O != "opponent" && $O != $W ]]
    then TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$O'")
      if [[ -z $TEAM_ID ]]
      then 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$O')")
      TEAM_ID=$($PSQL "SELECT team_id from teams WHERE name='$O'")
      fi
    fi

  fi
done

cat games.csv | while IFS="," read Y R W O W_G O_G
do
  W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$W' ")
  O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$O' ")

  if [[ $Y != 'year' ]]
  then 
    YEAR=$($PSQL "SELECT year FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")
    ROUND=$($PSQL "SELECT round FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")
    WIN_ID=$($PSQL "SELECT winner_id FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")
    OPP_ID=$($PSQL "SELECT opponent_id FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")
    WIN_G=$($PSQL "SELECT winner_goals FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")
    OPP_G=$($PSQL "SELECT opponent_goals FROM games WHERE winner_id=$W_ID AND opponent_id=$O_ID ")

    if [[ -z $YEAR && -z $ROUND && -z $WIN_ID && -z $OPP_ID && -z $WIN_G && -z $OPP_G ]]
    then 
      INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($Y, '$R', $W_ID, $O_ID, $W_G, $O_G)")
    fi
  fi    
done
