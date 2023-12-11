mod helpers;

use crate::helpers::*;
use regex::Regex;
use std::ops::Range;

fn main() {
    let mut lines = input_lines(EXAMPLE);
    lines.push("".to_string());

    let re_num = Regex::new("\\d+").unwrap();
    let re_sym = Regex::new("[*]").unwrap();

    let mut line2: String;
    let mut line3 = "".to_string();

    let mut num1: Vec<(Range<i32>, u32)>;
    let mut num2: Vec<(Range<i32>, u32)> = [].to_vec();
    let mut num3: Vec<(Range<i32>, u32)> = [].to_vec();

    let mut sum: u32 = 0;
    for line in lines {
        line2 = line3;
        line3 = line.clone();

        num1 = num2;
        num2 = num3;
        num3 = re_num
            .find_iter(line3.as_str())
            .map(|m| {
                let n: u32 = m.as_str().parse().unwrap();
                let s = m.start() as i32;
                let e = m.end() as i32;
                ((s..e), n)
            })
            .collect();

        for m in re_sym.find_iter(line2.as_str()) {
            let s = m.start() as i32;
            let mut adj: Vec<u32> = [].to_vec();

            for (k, v) in num1.iter() {
                if k.contains(&(s - 1)) || k.contains(&s) || k.contains(&(s + 1)) {
                    adj.push(*v);
                }
            }
            for (k, v) in num2.iter() {
                if k.contains(&(s - 1)) || k.contains(&(s + 1)) {
                    adj.push(*v);
                }
            }
            for (k, v) in num3.iter() {
                if k.contains(&(s - 1)) || k.contains(&s) || k.contains(&(s + 1)) {
                    adj.push(*v);
                }
            }
            if adj.len() == 2 {
                sum += adj[0] * adj[1]
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
