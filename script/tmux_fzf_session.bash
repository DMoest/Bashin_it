#!/usr/bin/env bash

# Use Find and Fuzzy Finder (fzf) to choose a folder from the given folders.
# --------------------------------------------------------------------------
# Search with a min and max depth to limit depth of folder structure.
# Only search for type d for directories
# Pipe result to fuzzy finder (fzf)
# Select the session name from the basename/folder name of the workdir.
# To avoid conflicts in TMUX allowed session namespace pipe to tr for replacement of dots.
session=$(find ~/work ~/personal ~/Documents/Studier/BTH/ ~/Documents/Studier/BTH/dbwebb-kurser/ -mindepth 1 -maxdepth 1 -type d | fzf)
session_name=$(basename "$session" | tr . _)

# echo "Session: $session"
# echo "Session name: $session_name"


# If tmux session does not exist.
# -------------------------------
#   Create a new session from session name.
#   Put the new session in the catalog directory (-c) returned in session variable.
#   Use flag -d for detach to avoid starting a tmux session inside another tmux session.
if ! tmux has-session -t "$session_name" 2> /dev/null; then
    echo "TMUX start session $session_name"

    tmux new-session -s "$session_name" -c "$session" -d
fi


# If new session already exists switch to it.
# -------------------------------------------
tmux switch-client -t "$session_name"
