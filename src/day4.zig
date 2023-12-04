const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var input = @embedFile("day4.txt");

fn day4() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        // Indexing after parsing
        var bingo = [_]bool{false} ** 100;

        var game_acc: i64 = 0;

        // Find separator
        const sep_idx = std.mem.indexOf(u8, line, ":").?;
        const game = line[sep_idx + 2 ..];

        // Find second separator
        const vsep_idx = std.mem.indexOf(u8, game, "|").?;
        const winning = game[0 .. vsep_idx - 1];
        const actual = game[vsep_idx + 2 ..];

        // Parse values
        var actualit = std.mem.tokenizeSequence(u8, actual, " ");
        while (actualit.next()) |value| {
            const v = try std.fmt.parseInt(usize, value, 10);
            bingo[v] = true;
        }

        // Find reference and accumulate
        var winningit = std.mem.tokenizeSequence(u8, winning, " ");
        while (winningit.next()) |value| {
            const v = try std.fmt.parseInt(usize, value, 10);
            if (bingo[v]) {
                if (game_acc == 0) {
                    game_acc = 1;
                } else {
                    game_acc *= 2;
                }
            }
        }

        acc += game_acc;
    }

    return acc;
}

fn day4p2() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;
    var gameid: usize = 1;

    // Combos is a queue used to count the number of copies.
    // If card 1 has 4 matching, combos[2,3,4,5] += 1 for the 4 next cards. Score = 1 (combos[1])
    // If card 2 has 2 matching, combos[3,4] += 1 for the next 2 cards. Score = 3 (score + combos[2])
    // Etc...
    var copies = [_]i64{1} ** 300;

    while (lines.next()) |line| : (gameid += 1) {
        if (line.len == 0) {
            continue;
        }

        var game_acc: i64 = 0;

        // Indexing after parsing
        var bingo = [_]bool{false} ** 100;

        // Find separator
        const sep_idx = std.mem.indexOf(u8, line, ":").?;
        const game = line[sep_idx + 2 ..];

        // Find second separator
        const vsep_idx = std.mem.indexOf(u8, game, "|").?;
        const winning = game[0 .. vsep_idx - 1];
        const actual = game[vsep_idx + 2 ..];

        // Parse values
        var actualit = std.mem.tokenizeSequence(u8, actual, " ");
        while (actualit.next()) |value| {
            const v = try std.fmt.parseInt(usize, value, 10);
            bingo[v] = true;
        }

        // Find reference and accumulate
        var winningit = std.mem.tokenizeSequence(u8, winning, " ");
        while (winningit.next()) |value| {
            const v = try std.fmt.parseInt(usize, value, 10);
            if (bingo[v]) {
                game_acc += 1;
            }
        }

        var i: usize = 0;
        while (i < game_acc) : (i += 1) {
            copies[gameid + i + 1] += 1 * copies[gameid];
        }

        acc += copies[gameid];
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var result = try day4();
    const p1_time = timer.lap();
    std.debug.print("day4 p1: {} in {}ns\n", .{ result, p1_time });
    result = try day4p2();
    const p2_time = timer.read();
    std.debug.print("day4 p2: {} in {}ns\n", .{ result, p2_time });
}
