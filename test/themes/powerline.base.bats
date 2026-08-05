# shellcheck shell=bats
# shellcheck disable=SC2034 # Variables consumed by externally-loaded powerline functions.

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors"
	load "${BASH_IT?}/themes/powerline/powerline.base.bash"
}

function local_setup() {
	LEFT_PROMPT=""
	SEGMENTS_AT_LEFT=0
	LAST_SEGMENT_COLOR=""
	unset POWERLINE_PROMPT_FOREGROUND_COLOR
}

@test "powerline base: __powerline_left_segment omits fg color code when POWERLINE_PROMPT_FOREGROUND_COLOR is unset" {
	__powerline_left_segment "hello|240"
	run printf '%s' "${LEFT_PROMPT}"
	refute_output --partial "38;5;"
	assert_output --partial "48;5;240"
}

@test "powerline base: __powerline_left_segment applies POWERLINE_PROMPT_FOREGROUND_COLOR when set" {
	POWERLINE_PROMPT_FOREGROUND_COLOR=15
	__powerline_left_segment "hello|240"
	run printf '%s' "${LEFT_PROMPT}"
	assert_output --partial "38;5;15"
	assert_output --partial "48;5;240"
}

@test "powerline base: __powerline_left_segment fg color changes take effect on each segment" {
	POWERLINE_PROMPT_FOREGROUND_COLOR=7
	__powerline_left_segment "first|32"
	__powerline_left_segment "second|240"
	run printf '%s' "${LEFT_PROMPT}"
	assert_output --partial "38;5;7"
}
