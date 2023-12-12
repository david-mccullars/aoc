mod helpers;

use crate::helpers::*;
use memoize::memoize;

fn parse(line: &str) -> (String, Vec<usize>) {
    let mut f = line.split(' ');
    let springs = f.next().unwrap_or_default().to_string();
    let groups = f
        .next()
        .unwrap_or_default()
        .split(',')
        .map(|v| v.parse::<usize>().unwrap_or_default())
        .collect::<Vec<_>>();
    (springs, groups)
}

#[memoize]
fn count_all(springs: String, counts: Vec<usize>) -> usize {
    match springs.chars().next() {
        Some('.') => count_all(springs[1..].to_string(), counts.clone()),
        Some('?') => {
            let maybe_spring: String = springs.replacen('?', "#", 1);
            count_all(maybe_spring, counts.clone())
                + count_all(springs[1..].to_string(), counts.clone())
        }
        Some('#') if counts.is_empty() && springs.contains('#') => 0,
        Some('#') if springs.len() < counts[0] => 0,
        Some('#') if springs[..counts[0]].contains('.') => 0,
        Some('#') if springs.len() == counts[0] => (counts.len() == 1) as usize,
        Some('#') if springs.chars().nth(counts[0]) == Some('#') => 0,
        Some('#') => count_all(springs[counts[0] + 1..].to_string(), counts[1..].to_vec()),
        None => counts.is_empty() as usize,
        _ => 0,
    }
}

fn main() {
    let lines = input_lines(EXAMPLE);
    let total: usize = lines
        .iter()
        .map(|line| parse(line))
        .map(|(springs, counts)| count_all(springs, counts))
        .sum();

    println!("{}", total);
}

const EXAMPLE: &str = "
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
";
