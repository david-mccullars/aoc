mod helpers;

use crate::helpers::*;

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

fn score(grid: &Grid) -> usize {
    grid.iter()
        .enumerate()
        .map(|(row, line)| (grid.len() - row) * line.iter().filter(|c| **c == 'O').count())
        .sum()
}

fn main() {
    let lines = input_lines(EXAMPLE);

    let mut grid: Grid = lines.iter().map(|line| line.chars().collect()).collect();
    slide(&mut grid);

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
