mod helpers;

use itertools::Itertools;
use crate::helpers::*;

type Pos = (usize, usize);

fn manhattan_distance(p1: Pos, p2: Pos) -> usize {
    let d1 = if p1.0 > p2.0 { p1.0 - p2.0 } else { p2.0 - p1.0 };
    let d2 = if p1.1 > p2.1 { p1.1 - p2.1 } else { p2.1 - p1.1 };
    d1 + d2
}

fn main() {
	let lines = input_lines(EXAMPLE);

    let mut rows: Vec<Vec<bool>> = vec!();
    for line in lines {
        let row: Vec<bool> = line.chars().map(|c| c == '#').collect();
        if !row.iter().any(|g| *g) {
            rows.push(row.clone());
        }
        rows.push(row);
    }
    let mut cols: Vec<Vec<bool>> = vec!();
    for col in transpose(rows) {
        if !col.iter().any(|g| *g) {
            cols.push(col.clone());
        }
        cols.push(col);
    }

    let mut galaxies: Vec<Pos> = vec!();
    for (row, gs) in transpose(cols).iter().enumerate() {
        for (col, g) in gs.iter().enumerate() {
            if *g {
                galaxies.push((row, col))
            }
        }
    }

    let mut step = 1;
    let result = galaxies.into_iter().combinations(2).fold(0, |n, pair| {
        let g1 = pair[0];
        let g2 = pair[1];
        //println!("{} | {:?} to {:?}\t{}", step, g1, g2, manhattan_distance(g1, g2));
        step += 1;
        n + manhattan_distance(g1, g2)
    });

	println!("{}", result);
}

const EXAMPLE: &str = "
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
";
