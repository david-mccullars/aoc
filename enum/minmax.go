package enum

import (
	"golang.org/x/exp/constraints"
)

// Max returns the maximal element in the slice
// (or the zero value for an empty slice).
func Max[T constraints.Ordered](values []T) (ret T) {
	for i, v := range values {
		if i == 0 || v > ret {
			ret = v
		}
	}
	return ret
}

// Max returns the N maximal elements in the slice
// (or the zero value for an empty slice).
func MaxN[T constraints.Ordered](values []T, n int) (ret []T) {
	for _, v := range values {
		j := 0
		for j < len(ret) && v > ret[j] {
			j++
		}
		if j == len(ret) {
			ret = append(ret, v)
		} else if j == 0 {
			ret = append([]T{v}, ret...)
		} else {
			ret = append(ret[:j], ret[j-1:]...)
			ret[j] = v
		}
		if len(ret) > n {
			ret = ret[1:]
		}
	}
	return ret
}

// Min returns the minimal element in the slice.
func Min[T constraints.Ordered](values []T) (ret T) {
	for i, v := range values {
		if i == 0 || v < ret {
			ret = v
		}
	}
	return ret
}

// Min returns the N minimal elements in the slice.
func MinN[T constraints.Ordered](values []T, n int) (ret []T) {
	for _, v := range values {
		j := 0
		for j < len(ret) && v < ret[j] {
			j++
		}
		if j == len(ret) {
			ret = append(ret, v)
		} else if j == 0 {
			ret = append([]T{v}, ret...)
		} else {
			ret = append(ret[:j], ret[j-1:]...)
			ret[j] = v
		}
		if len(ret) > n {
			ret = ret[1:]
		}
	}
	return ret
}

// MaxFunc returns the maximal element in the slice
// (or the zero value for an empty slice) using the
// provided lessFunc.
func MaxFunc[T any](values []T, lessFunc func(a, b T) bool) (ret T) {
	for i, v := range values {
		if i == 0 || !lessFunc(v, ret) {
			ret = v
		}
	}
	return ret
}

// MinFunc returns the minimal element in the slice
// (or the zero value for an empty slice) using the
// provided lessFunc.
func MinFunc[T any](values []T, lessFunc func(a, b T) bool) (ret T) {
	for i, v := range values {
		if i == 0 || lessFunc(v, ret) {
			ret = v
		}
	}
	return ret
}
