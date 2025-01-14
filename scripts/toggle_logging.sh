#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/variables.sh"
source "$CURRENT_DIR/shared.sh"


start_pipe_pane() {
	local file=$(expand_tmux_format_path "${logging_full_filename}")
	"$CURRENT_DIR/start_logging.sh" "${file}"
	display_message "Started logging to ${logging_full_filename}"
}

stop_pipe_pane() {
	tmux pipe-pane
	display_message "Ended logging to $logging_full_filename"
}

target_pane() {
	tmux display-message -p "#{pane_id}"
}

# save logging status in a pane variable
set_logging_variable() {
	local value="$1"
	local target_pane="$(target_pane)"
	tmux set-option -pqt "$target_pane" "@logging_active" "$value"
}

# check if logging is happening for the current pane
is_logging() {
	local target_pane="$(target_pane)"
	local current_pane_logging="$(tmux show-option -pqv "@logging_active")"
	if [ -z "$current_pane_logging" ]; then
		return 1
	else
		return 0
	fi
}

# starts/stop logging
toggle_pipe_pane() {
	if is_logging; then
		set_logging_variable ""
		stop_pipe_pane
	else
		set_logging_variable "logging"
		start_pipe_pane
	fi
}

main() {
	if supported_tmux_version_ok; then
		toggle_pipe_pane
	fi
}
main
