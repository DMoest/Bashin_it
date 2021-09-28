#!/usr/bin/env bash

# Use Find and Fuzzy Finder (fzf) to choose a folder from the given folders.
#   Search with a min and max depth to limit depth of folder structure.
#   Only search for type d for directories
#   Pipe result to fuzzy finder (fzf)
session=$(find ~/work ~/personal ~/Documents/Studier/BTH/dbwebb-kurser/ -mindepth 1 -maxdepth 1 -type d | fzf)
session_name=$(basename "$session")

echo "session: $session"
echo "session name: $session_name"


# If tmux session does not exist
# ------------------------------
#   Create a new session from session name.
#   Put the new session in the catalog directory (-c) returned in session variable.
#   Use flag -d for detach to avoid starting a tmux session inside another tmux session.
#
if ! tmux has-session -t "$session_name"; then
    echo "TMUX start session $session_name"

    tmux new-session -s "$session_name" -c "$session" -d
fi
