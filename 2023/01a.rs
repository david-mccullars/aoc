mod helpers;

use crate::helpers::*;

fn main() {
	let lines = input_lines(EXAMPLE);

    let numbers: Vec<u32> = lines.iter().map(|line| {
        let first = line.chars().find(|c| c.is_numeric()).unwrap();
        let last = line.chars().rev().find(|c| c.is_numeric()).unwrap();
        let n1 = first.to_string().parse::<u32>().unwrap();
        let n2 = last.to_string().parse::<u32>().unwrap();
        n1 * 10 + n2
    }).collect();

    let result: u32 = numbers.iter().sum();
	println!("{}", result);
}

const EXAMPLE: &str = "
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
";
