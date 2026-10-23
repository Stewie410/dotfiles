#!/usr/bin/env bash

unset -f expl

expl() {
	explorer "${@}"
	return 0
}
