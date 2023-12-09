use regex::{Captures, Regex};
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn input_file() -> String {
    let mut args = env::args();

    let re = Regex::new("/(\\d{4})-(\\d+)[ab]").unwrap();
    let bin = args.next().unwrap();
    let cap = re.captures(bin.as_str()).unwrap();

    format!("inputs/{}/{}.txt", cap.get(1).unwrap().as_str(), cap.get(2).unwrap().as_str())
}

#[allow(dead_code)]
pub fn input_lines(example: &str) -> Vec<String> {
    let mut args = env::args();
    if args.nth(1).unwrap_or("".to_string()) == "-t" {
        return example.trim().split("\n").map(str::to_string).collect();
    }

    let input_file = input_file();

    let file = File::open(&input_file);
    let file = match file {
        Ok(f) => f,
        Err(_) => {
            eprintln!("Failed to open input file {}", &input_file);
            std::process::exit(1);
        }
    };

    let reader = BufReader::new(file);
    let lines: Vec<String> = reader.lines().map(|line|
        match line {
            Ok(line) => line,
            Err(err) => {
                eprintln!("Failed to read line: {}", err);
                std::process::exit(1);
            }
        }
    ).collect();

    lines
}

#[allow(dead_code)]
pub fn input_lines_mapped<T: std::str::FromStr + Clone>(example: &str, default_value: T) -> Vec<T> {
    let lines = input_lines(example);

    let mapped: Vec<T> = lines.iter().map(|line|
        match line.parse::<T>() {
            Ok(num) => num,
            Err(_) => default_value.clone(),
        }
    ).collect();

    mapped
}

#[allow(dead_code)]
pub fn input_lines_u32(example: &str) -> Vec<u32> {
    input_lines_mapped(example, 0)
}

#[allow(dead_code)]
pub fn str_to_vec<T: std::str::FromStr + Clone>(s: &str) -> Vec<T> {
    s.split_whitespace().map(|s|
        match s.parse() {
            Ok(val) => val,
            Err(_) => {
                eprintln!("Failed to parse string: {}", s);
                std::process::exit(1);
            },
        }
    ).collect()
}

#[allow(dead_code)]
pub fn capture_to_vec<T: std::str::FromStr + Clone>(captures: &Captures, group: usize) -> Vec<T> {
    match captures.get(group) {
        Some(val) => str_to_vec(val.as_str()),
        None => {
            eprintln!("No such capture group: {:?}", captures);
            std::process::exit(1);
        },
    }
}
