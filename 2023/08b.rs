mod helpers;

use crate::helpers::*;
use num::integer::lcm;
use regex::*;
use std::collections::HashMap;

fn to_id(s: &str) -> u16 {
    s.chars()
        .fold(0, |a, c| 26 * a + (c.to_ascii_lowercase() as u16) - 97)
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

    let starts: Vec<&u16> = instructions.keys().filter(|id| *id % 26 == 0).collect();
    let cycles: Vec<usize> = starts
        .into_iter()
        .map(|start| {
            let mut pos = *start;
            let mut step = 0;
            while pos % 26 < 25 {
                let dir = directions[step % directions.len()];
                pos = if dir == 'L' {
                    instructions[&pos].0
                } else {
                    instructions[&pos].1
                };
                step += 1;
                if step > 100000 {
                    eprintln!("Too many steps!");
                    std::process::exit(1);
                }
            }
            step
        })
        .collect();

    let result = cycles.into_iter().fold(1, |a, b| lcm(a, b));
    println!("{}", result);
}

const EXAMPLE: &str = "
LR

AAA = (AAB, XXX)
AAB = (XXX, AAZ)
AAZ = (AAB, XXX)
BBA = (BBB, XXX)
BBB = (BBC, BBC)
BBC = (BBZ, BBZ)
BBZ = (BBB, BBB)
XXX = (XXX, XXX)
";
