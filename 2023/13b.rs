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
    let lines: Vec<Vec<char>> = text.lines().map(|line| line.chars().collect()).collect();
    let unfixed_reflection_row: Option<usize> = check(&lines, None);

    let mut flipped_lines = lines.clone();
    for (i, line) in lines.iter().enumerate() {
        for (j, c) in line.iter().enumerate() {
            flipped_lines[i][j] = flip(*c);
            if let Some(found) = check(&flipped_lines, unfixed_reflection_row) {
                return found;
            }
            flipped_lines[i][j] = *c;
        }
    }
    0
}

fn check(lines: &[Vec<char>], unfixed_reflection_row: Option<usize>) -> Option<usize> {
    let lines_ref: Vec<&[char]> = lines.iter().map(|line| line.as_slice()).collect();
    (1..lines.len())
        .filter(|row| unfixed_reflection_row != Some(*row) && is_mirror(&lines_ref, *row))
        .next()
}

fn flip(c: char) -> char {
    if c == '.' {
        '#'
    } else {
        '.'
    }
}

fn is_mirror(lines: &[&[char]], row: usize) -> bool {
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
