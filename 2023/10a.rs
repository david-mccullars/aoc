mod helpers;

use crate::helpers::*;

type Pos = (i32, i32);
type Pipe = (Pos, Pos);

const NORTH: Pos = (-1, 0);
const SOUTH: Pos = (1, 0);
const EAST: Pos = (0, 1);
const WEST: Pos = (0, -1);

fn dirs(c: char) -> Pipe {
    match c {
        '|' => (NORTH, SOUTH), // is a vertical pipe connecting north and south.
        '-' => (EAST, WEST),   // is a horizontal pipe connecting east and west.
        'L' => (NORTH, EAST),  // is a 90-degree bend connecting north and east.
        'J' => (NORTH, WEST),  // is a 90-degree bend connecting north and west.
        '7' => (SOUTH, WEST),  // is a 90-degree bend connecting south and west.
        'F' => (SOUTH, EAST),  // is a 90-degree bend connecting south and east.
        _ => todo!(),
    }
}

fn main() {
    let lines = input_lines(EXAMPLE);

    let mut start: Pos = (-1, -1);
    for (row, line) in lines.iter().enumerate() {
        for (col, c) in line.chars().enumerate() {
            if c == 'S' {
                start = (row as i32, col as i32);
            }
        }
    }

    let mut start_dirs: Vec<Pos> = vec![];
    let map: Vec<Vec<Option<Pipe>>> = lines
        .iter()
        .enumerate()
        .map(|(row, line)| {
            let row_map: Vec<Option<Pipe>> = line
                .chars()
                .enumerate()
                .map(|(col, c)| {
                    if c == '.' || c == 'S' {
                        None
                    } else {
                        let (d1, d2) = dirs(c);
                        let d1 = (row as i32 + d1.0, col as i32 + d1.1);
                        let d2 = (row as i32 + d2.0, col as i32 + d2.1);
                        if d1 == start || d2 == start {
                            start_dirs.push((row as i32, col as i32));
                        }
                        Some((d1, d2))
                    }
                })
                .collect();
            row_map
        })
        .collect();

    let mut prev_pos: Pos = start;
    let mut pos: Pos = start_dirs[0];
    let mut step = 1;
    while pos != start_dirs[1] {
        let (d1, d2) = map[pos.0 as usize][pos.1 as usize].unwrap();
        (prev_pos, pos) = if d1 == prev_pos { (pos, d2) } else { (pos, d1) };
        step += 1;
    }
    step += 1;

    println!("{}", step / 2);
}

const EXAMPLE: &str = "
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
";
