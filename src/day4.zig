const std = @import("std");

var input = @embedFile("day4.txt");
var input_test = @embedFile("day4_test.txt");

fn day4(data: []const u8) !i64 {
    var lines = std.mem.splitSequence(u8, data, "\n");

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

fn day4p2(data: []const u8) !i64 {
    var lines = std.mem.splitSequence(u8, data, "\n");

    var acc: i64 = 0;
    var gameid: usize = 1;

    // Copies is an array used to count the number of copies.
    // If card 1 has 4 matching, copies[2,3,4,5] += 1 for the 4 next cards. Score = 1 (copies[1])
    // If card 2 has 2 matching, copies[3,4] += 1 for the next 2 cards. Score = 3 (score + copies[2])
    // Etc...
    // We allow to do this because we know there is an ending and it's not worth it to dynamically allocate.
    var copies = [_]i64{1} ** 300; // We use 300, a hard-coded value for our buffer. No need for dynamc allocation.

    while (lines.next()) |line| : (gameid += 1) {
        if (line.len == 0) {
            continue;
        }

        var game_acc: usize = 0;

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

        for (copies[gameid + 1 .. gameid + game_acc + 1]) |*copy| {
            copy.* += copies[gameid];
        }

        acc += copies[gameid];
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day4(input);
    const p1_time = timer.lap();
    const result_p2 = try day4p2(input);
    const p2_time = timer.read();
    std.debug.print("day4 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day4 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day4" {
    const result = try day4(input_test);
    try std.testing.expect(result == 13);
}

test "day4p2" {
    const result = try day4p2(input_test);
    try std.testing.expect(result == 30);
}
