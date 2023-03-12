#!/bin/env bash

# Open AI Chatbot Script
# ----------------------
# Author: Daniel Andersson
# Date: 2023-03-05

# List of script dependencies
# ---------------------------
# bash
# fzf
# curl
# jq
#



# --- IMPORTANT ----------
# Setup OpenAI API Token needed for this script to work
# 1. CREATE AN ACCOUNT (or you already have one).
# 2. THEN CREATE THE TOKEN HERE -> https://platform.openai.com/account/api-keys"
# 3. EXPORT IT TO YOU GLOBAL ENV VARIABLES:
#     export OPENAI_API_KEY="<YOUR API KEY TOKEN HERE>
#     ...or put it in your shell ~/.<your_shell>rc file to load on startup.
#     (example: ~/.bashrc or .zshrc)


#
# Name & Version of the script.
# .............................
SCRIPT=$( basename "$0" )
VERSION="1.0.0"


#
# Define ANSI color codes
# -----------------------
no_color='\033[0m'
black_color='\033[0;30m'
red_color='\033[0;31m'
green_color='\033[0;32m'
yellow_color='\033[0;33m'
blue_color='\033[0;34m'
purple_color='\033[0;35m'
cyan_color='\033[0;36m'
gray_color='\033[0;37m'
white_color='\033[1;37m'


#
# Define the spinner animation for loading
# ----------------------------------------
spinner="/-\|"

#
# Define variables in use
# -----------------------
prompt_user="You: "
chatbot_prompt="ChatBot: "
selected_ai_model="gpt-3.5-turbo-0301"
latest_cb_response=""
output_msg=""



# FUNCTION - Print the welcome banner
# -----------------------------------
print_welcome_banner() {
echo -e "${green_color}                                              ${no_color}"
echo -e "${green_color}8\"\"\"\"8                   8\"\"\"\"8               ${no_color}"
echo -e "${green_color}8    \" e   e eeeee eeeee 8    8   eeeee eeeee ${no_color}"
echo -e "${green_color}8e     8   8 8   8   8   8eeee8ee 8  88   8   ${no_color}"
echo -e "${green_color}88     8eee8 8eee8   8e  88     8 8   8   8e  ${no_color}"
echo -e "${green_color}88   e 88  8 88  8   88  88     8 8   8   88  ${no_color}"
echo -e "${green_color}88eee8 88  8 88  8   88  88eeeee8 8eee8   88  ${no_color}"
echo -e "${green_color}                                              ${no_color}"
echo -e "${purple_color}.................................................${no_color}"
echo -e "${cyan_color}Version: $VERSION${no_color}"
echo -e "${cyan_color}Author: Daniel Andersson${no_color}"
echo -e "${cyan_color}Selected Model: $select_ai_model${no_color}"
echo -e " "
echo -e "${cyan_color}A CLI client to access the OpenAI API${no_color}"
echo -e "${cyan_color}Made for those quick 'one offs'..${no_color}"
}


# FUNCTION - Select the AI model
# ------------------------------
select_ai_model() {
selected_ai_model=$(echo "code-davinci-002
gpt-3.5-turbo
gpt-3.5-turbo-0301
text-davinci-002
text-davinci-003" | \
fzf --cycle --height 10 --ansi --layout=reverse-list --prompt="Select AI Model >")


# FUNCTION - Print the response from the ChatBot API
# --------------------------------------------------
echo -e "${green_color}Selected AI Model:${no_color} " $selected_ai_model
}


# FUNCTION - Print the selected AI model
# ---------------------------
print_selected_ai_model() {
     echo -e "${cyan_color}Selected AI Model:${no_color} " $selected_ai_model
}


# FUNCTION - Make the request to the OpenAI API
# ----------------------------------
make_gpt_request() {
# latest_cb_response=$(curl -s https://api.openai.com/v1/chat/completions \
#                          -H 'Content-Type: application/json' \
#                          -H "Authorization: Bearer $OPENAI_API_KEY" \
#                          -d "{\"model\": \"$1\", \"messages\": [{\"role\": \"user\", \"content\": \"$2\"}]}")

# Start the curl request in the background
curl -s https://api.openai.com/v1/chat/completions \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{\"model\": \"$1\", \"messages\": [{\"role\": \"user\", \"content\": \"$2\"}]}" > /tmp/latest_cb_response 2>&1 &

# Save the PID of the curl command
curl_pid=$!

# While the curl command is still running, display the spinner animation
while kill -0 $curl_pid 2>/dev/null; do
#     printf "\r%c" "${spinner:i++%${#spinner}:1}"
    printf "\r\033[0;36m%c\033[0m" "${spinner:i++%${#spinner}:1}"
    sleep 0.075
done

# When the curl command is finished, clear the spinner animation
printf "\r%s\n"

# Save the response from the curl request
latest_cb_response=$(cat /tmp/latest_cb_response)
}



# Print out the welcome banner on script startup
# ----------------------------------------------
print_welcome_banner
sleep 0.5 # Hold the welcome banner for 0.5 seconds



# The Game Loop
# -------------
while true; do

# Display the FZF prompt
CHOICES=$(echo "Ask ChatBot
Print Selected AI Model
Select AI Model
Clear Terminal
Quit" | fzf --cycle --height 10 --layout=reverse-list --prompt=" > ")
# --color='bg:#4B4B4B,bg+:#3F3F3F,info:#BDBB72,border:#6B6B6B,spinner:#98BC99' \
# --color='hl:#719872,fg:#D9D9D9,header:#719872,fg+:#D9D9D9' \
# --color='pointer:#E12672,marker:#E17899,prompt:#98BEDE,hl+:#98BC99'

sleep 0.1

    case $CHOICES in
        "Ask ChatBot")
            sleep 0.1

            # Get user input
            read -p "$prompt_user" message

            # Send message to OpenAI API
            echo "Awaiting ChatBot's answer..."
            make_gpt_request "$selected_ai_model" "$message"

            # Parse response using jq and extract the generated text message.content
            output_msg=$(echo "$latest_cb_response" | jq -r '.choices[].message.content')

            # Print the response from the chatbot
            echo -e "${green_color}${chatbot_prompt}"
            echo -e "${cyan_color}$output_msg${no_color}"
            echo " "

            # Wait for user to press ENTER before continuing
            read -rs -p "Press ENTER to continue... " -n 1 _
            ;;

#         "Display the Welcome prompt again...")
#             sleep 0.25
#             print_welcome_banner
#             sleep 0.25
#             ;;

        "Print Selected AI Model")
            sleep 0.1
            print_selected_ai_model
            sleep 0.25
            ;;

        "Select AI Model")
            echo "Choose the AI model you like..."
            sleep 0.1
            select_ai_model
            sleep 0.25
            ;;

        "Clear Terminal")
            sleep 0.1
            clear
            print_welcome_banner
            sleep 0.5
            ;;

        "Quit")
            echo "Quit ChatBot CLI App..."
            exit 0
            ;;

        *)
            echo "Invalid option..."
            ;;
    esac
done
