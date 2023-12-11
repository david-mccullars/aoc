mod helpers;

use crate::helpers::*;
use itertools::Itertools;

type Pos = (usize, usize);

fn manhattan_distance(p1: Pos, p2: Pos) -> usize {
    let d1 = if p1.0 > p2.0 {
        p1.0 - p2.0
    } else {
        p2.0 - p1.0
    };
    let d2 = if p1.1 > p2.1 {
        p1.1 - p2.1
    } else {
        p2.1 - p1.1
    };
    d1 + d2
}

const EXPANSION: usize = 1_000_000 - 1; // 1 million x

fn main() {
    let lines = input_lines(EXAMPLE);

    let map: Vec<Vec<bool>> = lines
        .iter()
        .map(|line| {
            let row: Vec<bool> = line.chars().map(|c| c == '#').collect();
            row
        })
        .collect();

    let empty_rows: Vec<usize> = map
        .iter()
        .enumerate()
        .filter(|(_, row)| !row.iter().any(|g| *g))
        .map(|(pos, _)| pos)
        .collect();
    let empty_cols: Vec<usize> = transpose(&map)
        .iter()
        .enumerate()
        .filter(|(_, col)| !col.iter().any(|g| *g))
        .map(|(pos, _)| pos)
        .collect();

    let mut galaxies: Vec<Pos> = vec![];
    let mut expanded_row = 0;
    for (row, gs) in map.iter().enumerate() {
        if empty_rows.contains(&row) {
            expanded_row += 1;
        }
        let mut expanded_col = 0;
        for (col, g) in gs.iter().enumerate() {
            if empty_cols.contains(&col) {
                expanded_col += 1;
            }
            if *g {
                galaxies.push((
                    row + EXPANSION * expanded_row,
                    col + EXPANSION * expanded_col,
                ))
            }
        }
    }

    let mut step = 1;
    let result = galaxies.into_iter().combinations(2).fold(0, |n, pair| {
        let g1 = pair[0];
        let g2 = pair[1];
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
