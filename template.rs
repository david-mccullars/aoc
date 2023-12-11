mod helpers;

use crate::helpers::*;

regex!(RE, r"Some \d+");

fn main() {
    let lines = input_lines(EXAMPLE);

    let _: Vec<_> = lines.iter().map(|_line| {}).collect();

    let result: u32 = 0;
    println!("{}", result);
}

const EXAMPLE: &str = "
";
