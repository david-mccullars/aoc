// -*- compile-command: "go run main.go ../example1.txt ../input.txt"; -*-

package main

import (
	"flag"
	"fmt"
	"log"

	. "github.com/david-mccullars/aoc/enum"
	"github.com/david-mccullars/aoc/must"
	"github.com/david-mccullars/aoc/strfn"
)

var logf = log.Printf
var printf = fmt.Printf

func main() {
	flag.Parse()

	Each(flag.Args(), process)
}

var LineGroups = strfn.Split("\n\n")
var Lines = strfn.Split("\n")
var MapToInt = func(s []string) []int { return Map(s, must.Atoi) }
var SumGroup = func(group string) int { return Sum(MapToInt(Lines(group))) }

func process(filename string) {
	logf("Processing %v ...", filename)
	buf := must.ReadFile(filename)

	countsByElf := Map(LineGroups(buf), SumGroup)
	maxsum := Sum(MaxN(countsByElf, 3))

	printf("Solution: %v\n", maxsum)
}
