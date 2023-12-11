mod helpers;

use itertools::Itertools;
use crate::helpers::*;

fn card(c: char) -> u16 {
    match c {
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        c => c.to_digit(10).unwrap() as u16,
    }
}

type Hand = Vec<u16>;

const FIVE_OF_A_KIND: u8 = 7;
const FOUR_OF_A_KIND: u8 = 6;
const FULL_HOUSE: u8 = 5;
const THREE_OF_A_KIND: u8 = 4;
const TWO_PAIR: u8 = 3;
const ONE_PAIR: u8 = 2;
const HIGH_CARD: u8 = 1;

fn score(cards: &Hand) -> u8 {
    let mut sorted_cards = cards.clone();
    sorted_cards.sort();

    let mut groups: Vec<u16> = vec!();
    for (_, group) in &sorted_cards.into_iter().group_by(|c| *c) {
        let len = group.collect::<Vec<u16>>().len() as u16;
		groups.push(len);
    }
    groups.sort();
    groups.reverse();

	if groups[0] == 5 {
		FIVE_OF_A_KIND
	} else if groups[0] == 4 {
		FOUR_OF_A_KIND
	} else if groups[0] == 3 && groups[1] == 2 {
		FULL_HOUSE
	} else if groups[0] == 3 {
		THREE_OF_A_KIND
	} else if groups[0] == 2 && groups[1] == 2 {
		TWO_PAIR
	} else if groups[0] == 2 {
		ONE_PAIR
	} else {
		HIGH_CARD
	}
}

fn main() {
	let lines = input_lines(EXAMPLE);

    let mut hands: Vec<(u8, Hand, u32)> = lines.iter().map(|line| {
        let line: Vec<_> = line.split_whitespace().collect();
        let hand: Hand = line[0].chars().map(card).collect();
        let bid: u32 = line[1].parse().unwrap();

        (score(&hand), hand, bid)
    }).collect();
    hands.sort(); // Use the hand (in sequence) as a tie-breaker

    let result: u32 = hands.iter().enumerate().fold(0, |n, (pos, (_, _, bid))|
        n + (pos as u32 + 1) * bid
    );
	println!("{}", result);
}

const EXAMPLE: &str = "
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
";
