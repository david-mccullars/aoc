mod helpers;

use std::collections::HashMap;
use regex::*;
use crate::helpers::*;

fn to_id(s: &str) -> u16 {
    s.chars().fold(0, |a, c| 26 * a + (c.to_ascii_lowercase() as u16) - 97)
}

fn main() {
	let lines = input_lines(EXAMPLE);
    let directions: Vec<char> = lines[0].chars().collect();

    let re = Regex::new(r"(...) = \((...), (...)\)").unwrap();

    let mut instructions: HashMap<u16, (u16, u16)> = HashMap::new();
    for line in lines[2..].to_vec() {
        let (_, [id, left, right]) = re.captures(line.as_str()).unwrap().extract();
        instructions.insert(to_id(id), (to_id(left), to_id(right)));
    }

    let start = to_id("AAA");
    let finish = to_id("ZZZ");

    let mut pos = start;
    let mut step = 0;
    while pos != finish {
        let dir = directions[step % directions.len()];
        pos = if dir == 'L' { instructions[&pos].0 } else { instructions[&pos].1 };
        step += 1;
        if step > 100000 {
            eprintln!("Too many steps!");
            std::process::exit(1);
        }
    }

	println!("{}", step);
}

const EXAMPLE: &str = "
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
";
