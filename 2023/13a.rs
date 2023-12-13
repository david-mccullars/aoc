mod helpers;

use crate::helpers::*;

fn main() {
    let text = input(EXAMPLE);
    let score: usize = text.split("\n\n").map(solve_either).sum();

    println!("{}", score);
}

fn solve_either(block: &str) -> usize {
    let s = solve(block);
    if s > 0 {
        s * 100
    } else {
        solve(&transpose_text(block))
    }
}

fn solve(text: &str) -> usize {
    let lines: Vec<&str> = text.lines().collect();
    (1..lines.len())
        .filter(|row| is_mirror(&lines, *row))
        .next()
        .unwrap_or_default()
}

fn is_mirror(lines: &[&str], row: usize) -> bool {
    (0..lines.len() - row)
        .take_while(|&i| i != row)
        .all(|i| lines[row - i - 1] == lines[row + i])
}

const EXAMPLE: &str = "
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
";
