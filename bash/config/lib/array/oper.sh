#!/usr/bin/env bash
# shellcheck disable=SC2178

# reverse order of array elements in-place (no extdebug)
# @param ref(array)
array.reverse() {
    local -n arr="${1}"
    local i

    (( ${#arr[@]} == 1 )) && return
    shift
    for (( i = ${#arr[@]} - 1; i >= 0; i-- )); do
        set -- "${@}" "${i}"
    done
    arr=( "${@}" )
}

# remove & return last element of array
# @param ref(array)
# @return T
array.pop() {
    local -n arr="${1}"
    printf '%s\n' "${arr[-1]}"
    unset 'arr[-1]'
}

# remove and return first element of array
# @param ref(array)
# @return T
array.shift() {
    local -n arr="${1}"
    printf '%s\n' "${arr[0]}"
    arr=( "${arr[@]:1}" )
}

# insertion sort, constrained to index 'until' if provided
# @param ref(array)
# @param until? number
array.insertion_sort() {
	local -n arr="${1}"
	(($# == 1)) &&
		set -- "${1}" "${#arr[@]}"

	local i j k
	for ((i = 1; i < ${2}; i++)); do
		((j = 0))
		for ((k = i - 1; k >= 0; k--)); do
			((arr[k] > arr[i])) &&
				((c++))
		done

		local x y
		for ((x = i , y = i - 1; j > 0; x-- , y-- , j--)); do
			((arr[x] = arr[x] ^ arr[y]))
			((arr[y] = arr[x] ^ arr[y]))
			((arr[x] = arr[x] ^ arr[y]))
		done
	done
}
