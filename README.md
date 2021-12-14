# advent-of-code-2021
Advent of Code 2021 🎄 Ruby Solutions by `@Aquaj`

README based on [Adrienne Tacke's AoC solutions repository](https://github.com/adriennetacke/advent-of-code-2020).

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## What is Advent of Code?
[Advent of Code](http://adventofcode.com) is an online event created by [Eric Wastl](https://twitter.com/ericwastl).
Each year, starting on Dec 1st, an advent calendar of small programming puzzles are unlocked once a day at midnight
(EST/UTC-5). Developers of all skill sets are encouraged to solve them in any programming language they choose!

## Advent of Code 2021 Story

You're minding your own business on a ship at sea when the overboard alarm goes off! You rush to see if you can help. Apparently, one of the Elves tripped and accidentally sent the sleigh keys flying into the ocean!

Before you know it, you're inside a submarine the Elves keep ready for situations like this. It's covered in Christmas lights (because of course it is), and it even has an experimental antenna that should be able to track the keys if you can boost its signal strength high enough; there's a little meter that indicates the antenna's signal strength by displaying 0-50 stars.

Your instincts tell you that in order to save Christmas, you'll need to get all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

## Context

**Done during [Le Wagon x AoC challenge](http://lewagon-aoc.herokuapp.com/)**

**These were not written as example of clean or efficient code** but are simply my attempts at finding the answers to
each day's puzzle as quickly as possible, with a minimal refactoring at the end of the exercise to improve readability.

Performance logging was added simply as a fun way to compare implementations with other competitors.

## Puzzles

<!-- On-hand emojis: ✔ 🌟 -->
|       | Day                                                                     | Part One | Part Two | Solutions
| :---: | -----                                                                   | :------: | :------: | :---:
|   ✔   | [Day 0: Sonar Sweep](https://adventofcode.com/2021/day/1)               |    🌟    |    🌟    | [Solution](day-01.rb)
|   ✔   | [Day 2: Dive!](https://adventofcode.com/2021/day/2)                     |    🌟    |    🌟    | [Solution](day-02.rb)
|   ✔   | [Day 3: Binary Diagnostic](https://adventofcode.com/2021/day/3)         |    🌟    |    🌟    | [Solution](day-03.rb)
|   ✔   | [Day 4: Giant Squid](https://adventofcode.com/2021/day/4)               |    🌟    |    🌟    | [Solution](day-04.rb)
|   ✔   | [Day 5: Hydrotherman Venture](https://adventofcode.com/2021/day/5)      |    🌟    |    🌟    | [Solution](day-05.rb)
|   ✔   | [Day 6: Lanternfish](https://adventofcode.com/2021/day/6)               |    🌟    |    🌟    | [Solution](day-06.rb)
|   ✔   | [Day 7: The Treachery of Whales](https://adventofcode.com/2021/day/7)   |    🌟    |    🌟    | [Solution](day-07.rb)
|   ✔   | [Day 8: Seven Segment Search](https://adventofcode.com/2021/day/8)      |    🌟    |    🌟    | [Solution](day-08.rb)
|   ✔   | [Day 9: Smoke Basin](https://adventofcode.com/2021/day/9)               |    🌟    |    🌟    | [Solution](day-09.rb)
|   ✔   | [Day 10: Syntax Scoring](https://adventofcode.com/2021/day/10)          |    🌟    |    🌟    | [Solution](day-10.rb)
|   ✔   | [Day 11: Dumbo Octopus](https://adventofcode.com/2021/day/11)           |    🌟    |    🌟    | [Solution](day-11.rb)
|   ✔   | [Day 12: Passage Pathing](https://adventofcode.com/2021/day/12)         |    🌟    |    🌟    | [Solution](day-12.rb)
|   ✔   | [Day 13: Transparent Origami](https://adventofcode.com/2021/day/13)     |    🌟    |    🌟    | [Solution](day-13.rb)
|   ✔   | [Day 14: Extended Polymerization](https://adventofcode.com/2021/day/14) |    🌟    |    🌟    | [Solution](day-14.rb)
|       | [Day 15: TBD](https://adventofcode.com/2021/day/15)                     |          |          | [Solution](day-15.rb)
|       | [Day 16: TBD](https://adventofcode.com/2021/day/16)                     |          |          | [Solution](day-16.rb)
|       | [Day 17: TBD](https://adventofcode.com/2021/day/17)                     |          |          | [Solution](day-17.rb)
|       | [Day 18: TBD](https://adventofcode.com/2021/day/18)                     |          |          | [Solution](day-18.rb)
|       | [Day 19: TBD](https://adventofcode.com/2021/day/19)                     |          |          | [Solution](day-19.rb)
|       | [Day 20: TBD](https://adventofcode.com/2021/day/20)                     |          |          | [Solution](day-20.rb)
|       | [Day 21: TBD](https://adventofcode.com/2021/day/21)                     |          |          | [Solution](day-21.rb)
|       | [Day 22: TBD](https://adventofcode.com/2021/day/22)                     |          |          | [Solution](day-22.rb)
|       | [Day 23: TBD](https://adventofcode.com/2021/day/23)                     |          |          | [Solution](day-23.rb)
|       | [Day 24: TBD](https://adventofcode.com/2021/day/24)                     |          |          | [Solution](day-24.rb)
|       | [Day 25: TBD](https://adventofcode.com/2021/day/25)                     |          |          | [Solution](day-25.rb)

## Running the code

Each day computes and displays the answers to both of the day questions and their computing time in ms. To run it type `ruby day<number>.rb`.

If the session cookie value is provided through the SESSION env variable (dotenv is available to provide it) — it will
fetch the input from the website and store it as a file under the `inputs/` folder on its first run.
