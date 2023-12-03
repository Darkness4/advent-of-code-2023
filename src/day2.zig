const std = @import("std");

var input = @embedFile("day2.txt");

fn day2() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;

    outer: while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        // Parse Game ID
        var id: i64 = 0;
        var it = std.mem.splitSequence(u8, line, ": ");
        if (it.next()) |x| {
            var gameit = std.mem.splitSequence(u8, x, " ");
            _ = gameit.next(); // "Game: "
            if (gameit.next()) |idstr| {
                id = try std.fmt.parseInt(i64, idstr, 10);
            }
        }
        // Parse the Game
        const max_red = 12;
        const max_green = 13;
        const max_blue = 14;
        if (it.next()) |game| {
            var roundit = std.mem.splitSequence(u8, game, "; ");
            while (roundit.next()) |round| {
                var handit = std.mem.splitSequence(u8, round, ", ");
                var red: i64 = 0;
                var green: i64 = 0;
                var blue: i64 = 0;

                // Parse "x green, y blue, z red"
                while (handit.next()) |hand| {
                    var n: i64 = 0;
                    var v = std.mem.splitSequence(u8, hand, " ");
                    if (v.next()) |nstr| {
                        n = try std.fmt.parseInt(i64, nstr, 10);
                    }
                    if (v.next()) |typ| {
                        if (std.mem.eql(u8, typ, "red")) {
                            red = n;
                        }
                        if (std.mem.eql(u8, typ, "green")) {
                            green = n;
                        }
                        if (std.mem.eql(u8, typ, "blue")) {
                            blue = n;
                        }
                    }
                }

                if (red > max_red or green > max_green or blue > max_blue) {
                    continue :outer;
                }
            }
        }
        // Finished parsing, game is valid
        acc += id;
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
        // Parse Game ID
        var id: i64 = 0;
        var it = std.mem.splitSequence(u8, line, ": ");
        if (it.next()) |x| {
            var gameit = std.mem.splitSequence(u8, x, " ");
            _ = gameit.next(); // "Game: "
            if (gameit.next()) |idstr| {
                id = try std.fmt.parseInt(i64, idstr, 10);
            }
        }
        // Parse the Game
        var req_red: i64 = 0;
        var req_green: i64 = 0;
        var req_blue: i64 = 0;
        if (it.next()) |game| {
            var roundit = std.mem.splitSequence(u8, game, "; ");
            while (roundit.next()) |round| {
                var handit = std.mem.splitSequence(u8, round, ", ");

                // Parse "x green, y blue, z red"
                while (handit.next()) |hand| {
                    var n: i64 = 0;
                    var v = std.mem.splitSequence(u8, hand, " ");
                    if (v.next()) |nstr| {
                        n = try std.fmt.parseInt(i64, nstr, 10);
                    }
                    if (v.next()) |typ| {
                        if (std.mem.eql(u8, typ, "red")) {
                            if (req_red <= n) {
                                req_red = n;
                            }
                        }
                        if (std.mem.eql(u8, typ, "green")) {
                            if (req_green <= n) {
                                req_green = n;
                            }
                        }
                        if (std.mem.eql(u8, typ, "blue")) {
                            if (req_blue <= n) {
                                req_blue = n;
                            }
                        }
                    }
                }
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
    std.debug.print("{} in {}ns\n", .{ result, p1_time });
    result = try day2p2();
    const p2_time = timer.read();
    std.debug.print("{} in {}ns\n", .{ result, p2_time });
}
