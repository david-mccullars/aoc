package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	days, _ := strconv.Atoi(os.Args[1])
	input := strings.Split(os.Args[2], ",")

	var counts [9]uint64
	var total uint64

	for _, s := range input {
		v, _ := strconv.Atoi(s)
		counts[v]++
		total++
	}

	for day := 0; day < days; day++ {
		bred := counts[day%9]
		total += bred
		counts[(day+7)%9] += bred
		fmt.Println(total)
	}
}
