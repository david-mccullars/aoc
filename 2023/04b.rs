mod helpers;

use crate::helpers::*;
use array_tool::vec::Intersect;

regex!(RE_LINE, r"Card\s+\d+:\s+(.*?)\s+\|\s+(.*)");

fn main() {
    let lines = input_lines(EXAMPLE);

    let mut cards: Vec<usize> = vec![1; lines.len()];
    for (pos, line) in lines.iter().enumerate() {
        let caps = RE_LINE.captures(line).unwrap();
        let winning: Vec<u32> = capture_to_vec(&caps, 1);
        let mine: Vec<u32> = capture_to_vec(&caps, 2);

        let bonus = winning.intersect(mine).len();
        for pos2 in (pos + 1)..(pos + 1 + bonus) {
            cards[pos2] += cards[pos];
        }
    }

    let sum: usize = cards.iter().sum();
    println!("{}", sum);
}

const EXAMPLE: &str = "
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
";
