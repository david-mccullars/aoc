mod helpers;

use crate::helpers::*;
use regex::*;

fn main() {
    let input = input(EXAMPLE);

    let re1 = Regex::new(r"Time:\s+(.*)").unwrap();
    let re2 = Regex::new(r"Distance:\s+(.*)").unwrap();

    let times: Vec<u32> = capture_to_vec(&re1.captures(input.as_str()).unwrap(), 1);
    let dist: Vec<u32> = capture_to_vec(&re2.captures(input.as_str()).unwrap(), 1);

    let races: Vec<(&u32, &u32)> = times.iter().zip(dist.iter()).collect();

    let wiggle: Vec<u32> = races
        .iter()
        .map(|(&t, &d)| {
            let i = ((t * t) as f32 - (4 * d) as f32).sqrt();
            let mut min: u32 = (((t as f32) - i) / 2.0).ceil() as u32;
            let mut max: u32 = (((t as f32) + i) / 2.0).floor() as u32;
            if min * t - min * min == d {
                min = min + 1
            }
            if max * t - max * max == d {
                max = max - 1
            }
            max - min + 1
        })
        .collect();

    let result: u32 = wiggle.iter().product();
    println!("{}", result);
}

const EXAMPLE: &str = "
Time:      7  15   30
Distance:  9  40  200
";
