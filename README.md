# Salesforce Quiz Leaderboard

## Description
This project solves the SRM Bajaj Finserv Health assignment using Salesforce Apex.

## Features
- Calls API 10 times (poll 0–9)
- Removes duplicate entries using (roundId + participant)
- Calculates total score per participant
- Sorts leaderboard in descending order
- Sends final result using POST API

## How it Works
- Uses HttpRequest for API calls
- Uses Set for duplicate handling
- Uses Map for score calculation

## File
- QuizLeaderboard.cls
