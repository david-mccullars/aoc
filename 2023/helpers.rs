use num::Num;
use regex::{Captures, Regex};
use std::env;
use std::fmt::Debug;
use std::fmt::Display;
use std::fs::{self, File};
use std::io::{BufRead, BufReader};

#[macro_export]
macro_rules! regex {
    ($name:ident, $e:expr) => {
        lazy_static::lazy_static! {
            static ref $name: regex::Regex = regex::Regex::new($e).unwrap();
        }
    };
}

fn input_file() -> String {
    let mut args = env::args();

    let re = Regex::new("/(\\d{4})-(\\d+)[ab]").unwrap();
    let bin = args.next().unwrap();
    let cap = re.captures(bin.as_str()).unwrap();

    format!(
        "inputs/{}/{}.txt",
        cap.get(1).unwrap().as_str(),
        cap.get(2).unwrap().as_str()
    )
}

#[allow(dead_code)]
pub fn input(example: &str) -> String {
    let mut args = env::args();
    if args.nth(1).unwrap_or("".to_string()) == "-t" {
        return example.trim().to_string();
    }

    let input_file = input_file();

    /*
    let file = File::open(&input_file);
    let file = match file {
        Ok(f) => f,
        Err(_) => {
            eprintln!("Failed to open input file {}", &input_file);
            std::process::exit(1);
        }
    };
    */

    fs::read_to_string(&input_file).unwrap_or_else(|e| {
        eprintln!("Failed to read input file {} ({})", &input_file, e);
        std::process::exit(1);
    })
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
    let lines: Vec<String> = reader
        .lines()
        .map(|line| match line {
            Ok(line) => line,
            Err(err) => {
                eprintln!("Failed to read line: {}", err);
                std::process::exit(1);
            }
        })
        .collect();

    lines
}

#[allow(dead_code)]
pub fn input_lines_mapped<T: std::str::FromStr + Clone>(example: &str, default_value: T) -> Vec<T> {
    let lines = input_lines(example);

    let mapped: Vec<T> = lines
        .iter()
        .map(|line| match line.parse::<T>() {
            Ok(num) => num,
            Err(_) => default_value.clone(),
        })
        .collect();

    mapped
}

#[allow(dead_code)]
pub fn input_lines_u32(example: &str) -> Vec<u32> {
    input_lines_mapped(example, 0)
}

#[allow(dead_code)]
pub fn str_to_vec<T: std::str::FromStr + Clone>(s: &str) -> Vec<T> {
    s.split_whitespace()
        .map(|s| match s.parse() {
            Ok(val) => val,
            Err(_) => {
                eprintln!("Failed to parse string: {}", s);
                std::process::exit(1);
            }
        })
        .collect()
}

#[allow(dead_code)]
pub fn capture_to_vec<T: std::str::FromStr + Clone>(captures: &Captures, group: usize) -> Vec<T> {
    match captures.get(group) {
        Some(val) => str_to_vec(val.as_str()),
        None => {
            eprintln!("No such capture group: {:?}", captures);
            std::process::exit(1);
        }
    }
}

// xs:      🟩🟩🟩        🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧              🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
// ys[0]:                                                 ⬜⬜⬜⬜⬜
//          🟩🟩🟩        🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// ys[1]:                                                                           ⬜⬜⬜⬜⬜⬜⬜⬜⬜
//          🟩🟩🟩        🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟪🟪🟪🟪
// ys[2]:                                                                                            ⬜⬜
//          🟩🟩🟩        🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟪🟪🟪🟪
// ys[3]:                 ⬜
//          🟩🟩🟩        🟧🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟪🟪🟪🟪
// ys[4]:                             ⬜⬜⬜
//          🟩🟩🟩        🟧🟫🟫🟫🟫🟫🟪🟪🟪🟨🟨🟨              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟪🟪🟪🟪
// ys[5]: ⬜⬜⬜⬜⬜⬜
//          🟩🟩🟩        🟦🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪              🟥🟥🟦🟦🟦🟦🟦🟦🟦🟦🟪🟪🟪🟪
#[allow(dead_code)]
pub fn range_split<T: Num + Ord + Copy + Debug + Display>(
    xs: Vec<(T, T)>,
    ys: Vec<(T, T)>,
) -> Vec<(T, T)> {
    let mut changed = xs;
    for y in ys {
        changed = changed.iter().flat_map(|x| range_split1(&x, &y)).collect();
        //println!("CHANGED {:?}   |   {:?}", y, changed);
    }
    changed
}

#[allow(dead_code)]
#[inline]
pub fn range_split1<T: Num + Ord + Copy + Display>(x: &(T, T), y: &(T, T)) -> Vec<(T, T)> {
    //     |  x  |                      |  x  |
    //              |  y  |         |     y       |
    //     |     |                      |     |
    if (x.1 <= y.0 || y.1 <= x.0) || (y.0 <= x.0 && x.1 <= y.1) {
        //println!("A: {:?} | {:?} | {:?} | {:?}", x.1 < y.0, y.1 <= x.0, y.0 <= x.0, x.1 <= y.1);
        vec![*x]

    //     |      x      |
    //         |  y  |
    //     |   |     |   |
    } else if x.0 < y.0 && y.1 < x.1 {
        //println!("B");
        vec![(x.0, y.0), (y.0, y.1), (y.1, x.1)]

    //     |  x  |
    //  |  y  |
    //     |  |  |
    } else if y.0 <= x.0 {
        //println!("C");
        vec![(x.0, y.1), (y.1, x.1)]

    //     |  x  |
    //        |  y  |
    //     |  |  |
    } else if x.0 <= y.0 {
        //println!("D");
        vec![(x.0, y.0), (y.0, x.1)]
    } else {
        eprintln!(
            "Unexpected ranges: ({}, {}) and ({}, {})",
            x.0, x.1, y.0, y.1
        );
        std::process::exit(1);
    }
}

#[allow(dead_code)]
#[inline]
pub fn range_overlap1<T: Num + Ord + Copy + Display>(x: &(T, T), y: &(T, T)) -> bool {
    x.0 < y.1 && y.0 < x.1
}

#[allow(dead_code)]
pub fn transpose<T: Copy>(data: &Vec<Vec<T>>) -> Vec<Vec<T>> {
    let rows = data.len();
    let cols = data[0].len();
    (0..cols)
        .map(|col| (0..rows).map(|row| data[row][col]).collect())
        .collect()
}
