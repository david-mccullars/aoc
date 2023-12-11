mod helpers;

use crate::helpers::*;

regex!(RE, r"\d+");

fn main() {
    let input = input(EXAMPLE).replace(" ", "");

    let td: Vec<u64> = RE
        .captures_iter(input.as_str())
        .map(|s| s.get(0).unwrap().as_str().parse::<u64>().unwrap())
        .collect();
    let [t, d]: [u64; 2] = td.try_into().unwrap();

    let i = ((t * t) as f64 - (4 * d) as f64).sqrt();
    let mut min: u64 = (((t as f64) - i) / 2.0).ceil() as u64;
    let mut max: u64 = (((t as f64) + i) / 2.0).floor() as u64;
    if min * t - min * min == d {
        min = min + 1
    }
    if max * t - max * max == d {
        max = max - 1
    }

    let result: u64 = max - min + 1;
    println!("{}", result);
}

const EXAMPLE: &str = "
Time:      7  15   30
Distance:  9  40  200
";
