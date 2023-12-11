mod helpers;

use crate::helpers::*;
use regex::Regex;

fn main() {
    let mut lines = input_lines(EXAMPLE);
    lines.push("".to_string());

    let re_num = Regex::new("\\d+").unwrap();
    let re_sym = Regex::new("[^0-9.]").unwrap();

    let mut line2: String;
    let mut line3 = "".to_string();

    let mut sym1: Vec<i32>;
    let mut sym2: Vec<i32> = [].to_vec();
    let mut sym3: Vec<i32> = [].to_vec();

    let mut sum: u32 = 0;
    for line in lines {
        line2 = line3;
        line3 = line.clone();

        sym1 = sym2;
        sym2 = sym3;
        sym3 = re_sym
            .find_iter(line3.as_str())
            .map(|s| s.start() as i32)
            .collect();

        for m in re_num.find_iter(line2.as_str()) {
            let n: u32 = m.as_str().parse().unwrap();
            let mut near_sym = false;

            let s = m.start() as i32 - 1;
            let e = m.end() as i32;
            if sym2.contains(&s) || sym2.contains(&e) {
                near_sym = true;
            } else {
                for i in s..=e {
                    if sym1.contains(&i) || sym3.contains(&i) {
                        near_sym = true;
                        break;
                    }
                }
            }
            if near_sym {
                sum += n;
            }
        }
    }

    println!("{}", sum);
}

const EXAMPLE: &str = "
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
";
