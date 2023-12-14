mod helpers;

use crate::helpers::*;
use std::collections::HashMap;

const MAX_CYCLES: usize = 1000000000;

type Grid = Vec<Vec<char>>;

fn slide(grid: &mut Grid) {
    for col in 0..grid[0].len() {
        let mut fallrow = 0;
        for row in 0..grid.len() {
            match grid[row][col] {
                '#' => {
                    fallrow = row + 1;
                }
                '.' => {}
                'O' if fallrow < row => {
                    grid[fallrow][col] = 'O';
                    grid[row][col] = '.';
                    fallrow += 1;
                }
                'O' => {
                    fallrow = row + 1;
                }
                _ => todo!(),
            }
        }
    }
}

fn slide_cycle(grid: &mut Grid) {
    for _ in 0..4 {
        slide(grid);
        rotate_mut(grid);
    }
}

fn score(grid: &Grid) -> usize {
    grid.iter()
        .enumerate()
        .map(|(row, line)| (grid.len() - row) * line.iter().filter(|c| **c == 'O').count())
        .sum()
}

fn main() {
    let lines = input_lines(EXAMPLE);

    let mut grid: Grid = lines.iter().map(|line| line.chars().collect()).collect();

    let mut cache: HashMap<Grid, usize> = HashMap::new();
    let mut i = 0;
    while i < MAX_CYCLES {
        slide_cycle(&mut grid);

        let key = grid.clone();
        if cache.contains_key(&key) {
            let cycle_start = *cache.get(&key).unwrap();
            let cycle_size = i - cycle_start;
            cache.clear();
            i += ((MAX_CYCLES - i) / cycle_size) * cycle_size + 1;
        } else {
            cache.insert(key, i);
            i += 1;
        }
    }

    println!("{}", score(&grid));
}

const EXAMPLE: &str = "
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
";
