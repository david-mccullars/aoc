mod helpers;

use regex::*;
use crate::helpers::*;

fn main() {
	let lines = input_lines(EXAMPLE);

    let re = Regex::new(r"Some \d+").unwrap();

    let _: Vec<_> = lines.iter().map(|line| {
    }).collect();

    let result: u32 = 0;
	println!("{}", result);
}

const EXAMPLE: &str = "
";
