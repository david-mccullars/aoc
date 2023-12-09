mod helpers;

use regex::Regex;
use phf::phf_map;
use crate::helpers::*;

static NUMBER_NAMES: phf::Map<&'static str, u32> = phf_map! {
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
};

fn find_num(line: &String, re: &Regex) -> u32 {
	let cap = re.captures(line).unwrap();
	let n = cap.get(1).unwrap().as_str();
	match NUMBER_NAMES.get(n) {
		Some(v) => *v,
		None => n.parse::<u32>().unwrap(),
	}
}

fn main() {
	let lines = input_lines(EXAMPLE);

    let re_first = Regex::new("(\\d|one|two|three|four|five|six|seven|eight|nine)").unwrap();
    let re_last = Regex::new(".*(\\d|one|two|three|four|five|six|seven|eight|nine)").unwrap();

    let numbers: Vec<u32> = lines.iter().map(|line| {
		let n1 = find_num(&line, &re_first);
		let n2 = find_num(&line, &re_last);

        n1 * 10 + n2
    }).collect();

    let result: u32 = numbers.iter().sum();
	println!("{}", result);
}

const EXAMPLE: &str = "
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
";
