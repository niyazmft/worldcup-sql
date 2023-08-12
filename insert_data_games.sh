#! /bin/bash

if [[ $1 == "test" ]]; then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Function to insert team into teams table if not exists
insert_team() {
    local team_name="$1"
    local query="INSERT INTO teams(name) VALUES('$team_name') ON CONFLICT DO NOTHING; SELECT team_id FROM teams WHERE name='$team_name';"
    echo $($PSQL "$query")
}

# Function to find team_id for winner and opponent from teams table
find_team() {
    local team_name="$1"
    local query="SELECT team_id FROM teams WHERE name='$team_name'"
    echo $($PSQL "$query")
}

# Truncate tables
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Read CSV file starting from the second line
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    # Insert winner team
    winner_team_id=$(insert_team "$WINNER")

    # Insert opponent team
    opponent_team_id=$(insert_team "$OPPONENT")

    winner_tm_id=$(find_team "$WINNER")
    opponent_tm_id=$(find_team "$OPPONENT")
    
    # Execute the INSERT statement directly without echoing
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $winner_tm_id, $opponent_tm_id, $WINNER_GOALS, $OPPONENT_GOALS);"
done
