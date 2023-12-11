mod helpers;

use crate::helpers::*;

regex!(RE_SEEDS, r"seeds: ([0-9 ]+)");
regex!(RE_MAPS, r"(\S+)-to-(\S+) map:\s+([0-9\s]+)");

fn main() {
    let input = input(EXAMPLE);

    let mut ids: Vec<u64> = capture_to_vec(&RE_SEEDS.captures(input.as_str()).unwrap(), 1);
    for cap in RE_MAPS.captures_iter(input.as_str()) {
        let (_, [_, _, data]) = cap.extract();
        let maps: Vec<(u64, u64, i64)> = str_to_vec::<u64>(data)
            .chunks(3)
            .map(|chunk| {
                let min = chunk[1];
                let max = chunk[1] + chunk[2];
                let delta = (chunk[0] as i64) - (chunk[1] as i64);
                (min, max, delta)
            })
            .collect();

        for pos in 0..ids.len() {
            for (min, max, delta) in &maps {
                if (*min..*max).contains(&ids[pos]) {
                    ids[pos] = ((ids[pos] as i64) + delta) as u64;
                    break;
                }
            }
        }
    }

    let result: u64 = *ids.iter().min().unwrap();
    println!("{}", result);
}

const EXAMPLE: &str = "
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
";
