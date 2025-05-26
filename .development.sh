#!/bin/zsh
# set -x # Enable debugging: print commands and their arguments as they are executed

# Remove comments if placing files in different directory. Just remember to update the file path

# --- Configuration ---
SESSION_NAME="development"
PROJECT_NAME="btlarkin.github.io"
PROJECT_PATH="$HOME/repos/$PROJECT_NAME" # Define the full path for clarity

# --- Check if session exists and create if not ---
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Creating new tmux session: $SESSION_NAME"

    # Create new tmux session, name the first window 'editor', and detach.
    # This creates window 1 (due to base-index 1 in tmux.conf), with pane 1.1.
    tmux new -s "$SESSION_NAME" -n editor -d
    sleep 0.2 # Give tmux a moment to register the new session and window

    # --- Configure 'editor' window (Window 1) ---

    # Pane 1.1: Open index.html in Vim
    tmux send-keys -t "${SESSION_NAME}:1.1" "clear" C-m
    sleep 0.5
#    tmux send-keys -t "${SESSION_NAME}:1.1" "cd ${PROJECT_PATH}" C-m
#    sleep 0.5
    if [ -f "${PROJECT_PATH}/index.html" ]; then
        tmux send-keys -t "${SESSION_NAME}:1.1" "vim index.html" C-m
    else
        tmux send-keys -t "${SESSION_NAME}:1.1" "echo 'index.html not found in ${PROJECT_PATH}'" C-m
    fi

    # Split the 'editor' window vertically. This creates pane 1.2.
    tmux split-window -v -t "${SESSION_NAME}:1"
    sleep 0.5 # Give tmux a moment to create the new pane

    # Pane 1.2: Open index.html in browser for preview
    tmux send-keys -t "${SESSION_NAME}:1.2" "clear" C-m
    sleep 0.5
#    tmux send-keys -t "${SESSION_NAME}:1.2" "cd ${PROJECT_PATH}" C-m
#    sleep 0.5
    if [ -f "${PROJECT_PATH}/index.html" ]; then
        # Start BrowserSync with quoted file patterns for Zsh compatibility
        tmux send-keys -t "${SESSION_NAME}:1.2" "browser-sync start --server --files \"*.html,*.css,*.js\"" C-m
    else
        tmux send-keys -t "${SESSION_NAME}:1.2" "echo 'index.html not found in ${PROJECT_PATH}'" C-m
    fi

    # Set the layout of window 1.
    tmux select-layout -t "${SESSION_NAME}:1" main-horizontal

    # --- Configure 'console' window (Window 2) ---

    # Create a new full-screen window named 'console'.
    tmux new-window -n console -t "${SESSION_NAME}"
    sleep 0.5 # Give tmux a moment to register the new window
    tmux select-window -t "${SESSION_NAME}:2" # Select the newly created window

    # Clear the console pane (console.1) and change directory.
    tmux send-keys -t "${SESSION_NAME}:2.1" "clear" C-m
    sleep 0.5
    tmux send-keys -t "${SESSION_NAME}:2.1" "cd ${PROJECT_PATH}" C-m
    sleep 0.5

    # --- Configure dedicated windows for CSS and JS files ---

    # CSS Window: Create a new window for style.css if it exists
    if [ -f "${PROJECT_PATH}/style.css" ]; then
        tmux new-window -n css -t "${SESSION_NAME}"
        sleep 0.5 # Give tmux a moment to register the new window
        tmux select-window -t "${SESSION_NAME}:3" # Select the newly created window
        # Explicitly target pane 1 of the 'css' window.
        tmux send-keys -t "${SESSION_NAME}:3.1" "clear" C-m
        sleep 0.5
        tmux send-keys -t "${SESSION_NAME}:3.1" "cd ${PROJECT_PATH}" C-m
        sleep 0.5
        tmux send-keys -t "${SESSION_NAME}:3.1" "vim style.css" C-m
    fi

    # JS Window: Create a new window for script.js if it exists
    if [ -f "${PROJECT_PATH}/app.js" ]; then
        tmux new-window -n js -t "${SESSION_NAME}"
        sleep 0.5 # Give tmux a moment to register the new window
        tmux select-window -t "${SESSION_NAME}:4" # Select the newly created window
        # Explicitly target pane 1 of the 'js' window.
        tmux send-keys -t "${SESSION_NAME}:4.1" "clear" C-m
        sleep 0.5
#        tmux send-keys -t "${SESSION_NAME}:4.1" "cd ${PROJECT_PATH}" C-m
#        sleep 0.5
        tmux send-keys -t "${SESSION_NAME}:4.1" "vim app.js" C-m
    fi

    # Select the 'editor' window (Window 1) to be active when attaching.
    tmux select-window -t "${SESSION_NAME}:1"
fi

# Attach to the tmux session, whether it was newly created or already existed
tmux attach -t "${SESSION_NAME}"

