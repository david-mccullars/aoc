mod helpers;

use crate::helpers::*;
use phf::phf_map;
use regex::Regex;

regex!(
    RE_FIRST,
    "(\\d|one|two|three|four|five|six|seven|eight|nine)"
);
regex!(
    RE_LAST,
    ".*(\\d|one|two|three|four|five|six|seven|eight|nine)"
);

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

fn parse(line: &String) -> u32 {
    let n1 = find_num(&line, &RE_FIRST);
    let n2 = find_num(&line, &RE_LAST);
    n1 * 10 + n2
}

fn main() {
    let lines = input_lines(EXAMPLE);
    let sum: u32 = lines.iter().map(parse).sum();
    println!("{}", sum);
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
