const std = @import("std");

var input = @embedFile("day2.txt");

fn day2() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;
    var gameid: i64 = 1;

    outer: while (lines.next()) |line| : (gameid += 1) {
        if (line.len == 0) {
            continue;
        }
        // Parse Game ID
        const gamedel = std.mem.indexOf(u8, line, ":").?;
        const game = line[gamedel + 2 ..];

        // Parse the Game
        const max_red = 12;
        const max_green = 13;
        const max_blue = 14;
        var roundit = std.mem.splitSequence(u8, game, "; ");
        while (roundit.next()) |round| {
            var handit = std.mem.splitSequence(u8, round, ", ");
            var red: i64 = 0;
            var green: i64 = 0;
            var blue: i64 = 0;

            // Parse "x green, y blue, z red"
            while (handit.next()) |hand| {
                const handdel = std.mem.indexOf(u8, hand, " ").?;
                const n = try std.fmt.parseInt(i64, hand[0..handdel], 10);
                switch (hand[handdel + 1]) {
                    'r' => red = n,
                    'g' => green = n,
                    'b' => blue = n,
                    else => unreachable,
                }
            }

            if (red > max_red or green > max_green or blue > max_blue) {
                continue :outer;
            }
        }
        // Finished parsing, game is valid
        acc += gameid;
    }

    return acc;
}

fn day2p2() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const gamedel = std.mem.indexOf(u8, line, ":").?;

        // Parse the Game
        var req_red: i64 = 0;
        var req_green: i64 = 0;
        var req_blue: i64 = 0;
        const game = line[gamedel + 2 ..];
        var begin: usize = 0;
        for (0.., game) |i, char| {
            if (char == ',' or char == ';' or i == game.len - 1) { // Split either ',' or ';' or EOL.
                var offset: usize = 0;
                if (i == game.len - 1) {
                    offset = 1;
                }
                const hand = game[begin .. i + offset];
                const handdel = std.mem.indexOf(u8, hand, " ").?;
                const n = try std.fmt.parseInt(i64, hand[0..handdel], 10);
                switch (hand[handdel + 1]) {
                    'r' => if (req_red < n) {
                        req_red = n;
                    },
                    'g' => if (req_green < n) {
                        req_green = n;
                    },
                    'b' => if (req_blue < n) {
                        req_blue = n;
                    },
                    else => unreachable,
                }
                begin = i + 1 + 1; // +1 to skip space
            }
        }
        // Finished parsing, add required.
        acc += req_red * req_green * req_blue;
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var result = try day2();
    const p1_time = timer.lap();
    std.debug.print("day2 p1: {} in {}ns\n", .{ result, p1_time });
    result = try day2p2();
    const p2_time = timer.read();
    std.debug.print("day2 p2: {} in {}ns\n", .{ result, p2_time });
}
