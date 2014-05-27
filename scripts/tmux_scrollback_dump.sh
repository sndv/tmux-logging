#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_scrollback_path="$HOME"
default_scrollback_name="tmux-scrollback-#{session_name}-#{window_index}-#{pane_index}-%Y%m%dT%H%M%S.log"

source $CURRENT_DIR/shared.sh

get_scrollback_path() {
	get_tmux_option "@ppp_scrollback_path" "$default_scrollback_path"
}

# `tmux save-buffer` command does not perform interpolation, so we're doing it
# "manually" with `display-message`
get_scrollback_name() {
	local name_template=$(get_tmux_option "@ppp_scrollback_name" "$default_scrollback_name")
	tmux display-message -p "$name_template"
}

scrollback_dump() {
	local scrollback_path=$(get_scrollback_path)
	local scrollback_name=$(get_scrollback_name)
	# copying 9M lines back in the past will hopefully fetch all the history
	tmux capture-pane -S -9000000
	tmux save-buffer "$scrollback_path/$scrollback_name"
	tmux delete-buffer
	display_message "Scrollback saved to $scrollback_path/$scrollback_name"
}

main() {
	scrollback_dump
}
main