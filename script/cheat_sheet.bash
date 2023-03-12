#!/use/bin/env bash

# List of script dependencies
# ---------------------------
# fzf (fuzzy finder)
# tmux (terminal multiplexer)
# less
# tr
# curl cht.sh (cheat sheet)


# list of languages
languages=$(echo "bash c css docker django express git javascript jest jwt laravel mongo node php python rust sql tmux vim vue" | tr " " "\n")

# list of core utils
core_utils=$(echo "alias awk cat cd cp curl export file find grep head jq less locate ls ln mkdir mount mv printenv pwd rm rsync stat sed set sort sudo tail tee touch uniq unmount wc" | tr " " "\n")
selected=$(echo -e "$languages\n ---------- \n $core_utils" | fzf)


# Promt to ask what to learn about the thing
read -p "What do you wish to learn in $selected? " $query

echo "$query"

# Depending on the tool set. Language/Core Utils.
if echo "$languages" | grep -qs $selected; then
    # tmux split-window -h -p 40 bash -c "curl cht.sh/$selected/$(echo "$query" | tr " " "+") | less -R"
    bash -c "curl cht.sh/$selected/$(echo "$query" | tr " " "+") | less -R"
else
    # tmux split-window -h -p 40 bash -c "curl cht.sh/$selected~$query | less -R"
    bash -c "curl cht.sh/$selected~$query | less -R"
fi
