mod helpers;

use crate::helpers::*;

fn main() {
    let lines = input_lines(EXAMPLE);

    let predictions: Vec<i32> = lines
        .iter()
        .map(|line| {
            let mut rows: Vec<Vec<i32>> = vec![];
            let mut row: Vec<i32> = str_to_vec(line.as_str());
            rows.push(row.clone());
            while row.iter().any(|i| *i != 0) {
                row = row.windows(2).map(|a| a[1] - a[0]).collect();
                rows.push(row.clone());
            }
            rows.reverse();

            rows.iter().fold(0, |n, row| n + row[row.len() - 1])
        })
        .collect();

    let result: i32 = predictions.iter().sum();
    println!("{}", result);
}

const EXAMPLE: &str = "
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
";