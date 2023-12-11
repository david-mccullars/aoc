mod helpers;

use crate::helpers::*;
use regex::Regex;

#[derive(Debug, Clone, Copy)]
struct Rgb {
    r: u32,
    g: u32,
    b: u32,
}

impl Rgb {
    fn new(s: &str, re: &Regex) -> Self {
        let mut r = 0;
        let mut g = 0;
        let mut b = 0;

        for (_, [v, c]) in re.captures_iter(s).map(|c| c.extract()) {
            let v = v.parse::<u32>().unwrap();
            match c {
                "red" => r = v,
                "green" => g = v,
                "blue" => b = v,
                &_ => {}
            }
        }

        Rgb { r, g, b }
    }

    fn is_less_or_equal(&self, other: &Self) -> bool {
        self.r <= other.r && self.g <= other.g && self.b <= other.b
    }
}

fn main() {
    let lines = input_lines(EXAMPLE);

    let re_game = Regex::new("^Game (\\d+): (.*)").unwrap();
    let re_color = Regex::new("(\\d+) (blue|red|green)").unwrap();
    let possible = Rgb {
        r: 12,
        g: 13,
        b: 14,
    };

    let mut sum = 0;
    for line in lines {
        let (_, [id, games]) = re_game.captures(line.as_str()).unwrap().extract();
        let sets: Vec<Rgb> = games.split("; ").map(|g| Rgb::new(g, &re_color)).collect();
        let all_possible = sets.iter().all(|&set| set.is_less_or_equal(&possible));
        if all_possible {
            sum += id.parse::<u32>().unwrap();
        }
    }

    println!("{}", sum);
}

const EXAMPLE: &str = "
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
";
