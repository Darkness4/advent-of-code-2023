const std = @import("std");

var input = @embedFile("day1.txt");

fn findFirstDigit(data: []const u8) u8 {
    for (data) |char| {
        if (char >= '0' and char <= '9') {
            return char - '0';
        }
    }
    return 0;
}

fn findLastDigit(data: []const u8) u8 {
    var ch: u8 = 0;
    for (data) |char| {
        if (char >= '0' and char <= '9') {
            ch = char - '0';
        }
    }
    return ch;
}

fn day1() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        acc += findFirstDigit(line) * 10 + findLastDigit(line);
    }

    return acc;
}

fn wordToInt(data: []const u8, index: usize, ch: u8) u8 {
    switch (ch) {
        't' => {
            // Check two
            if (data.len - index >= 3 and std.mem.eql(u8, data[index .. index + 3], "two")) {
                return 2;
            }

            if (data.len - index >= 5 and std.mem.eql(u8, data[index .. index + 5], "three")) {
                return 3;
            }
        },
        'o' => {
            if (data.len - index >= 3 and std.mem.eql(u8, data[index .. index + 3], "one")) {
                return 1;
            }
        },
        'f' => {
            if (data.len - index >= 4 and std.mem.eql(u8, data[index .. index + 4], "four")) {
                return 4;
            }
            if (data.len - index >= 4 and std.mem.eql(u8, data[index .. index + 4], "five")) {
                return 5;
            }
        },
        's' => {
            if (data.len - index >= 3 and std.mem.eql(u8, data[index .. index + 3], "six")) {
                return 6;
            }
            if (data.len - index >= 5 and std.mem.eql(u8, data[index .. index + 5], "seven")) {
                return 7;
            }
        },
        'e' => {
            if (data.len - index >= 5 and std.mem.eql(u8, data[index .. index + 5], "eight")) {
                return 8;
            }
        },
        'n' => {
            if (data.len - index >= 4 and std.mem.eql(u8, data[index .. index + 4], "nine")) {
                return 9;
            }
        },
        else => {},
    }
    return 0;
}

fn findFirstWordDigit(data: []const u8) u8 {
    for (0.., data) |i, char| {
        // Is Int
        if (char <= '9' and char >= '0') {
            return char - '0';
        }

        const v = wordToInt(data, i, char);
        if (v != 0) {
            return v;
        }
    }
    return 0;
}

fn findLastWordDigit(data: []const u8) u8 {
    var ch: u8 = 0;
    for (0.., data) |i, char| {
        if (char <= '9' and char >= '0') {
            ch = char - '0';
        }
        const v = wordToInt(data, i, char);
        if (v != 0) {
            ch = v;
        }
    }
    return ch;
}

fn day1p2() !i64 {
    var lines = std.mem.splitSequence(u8, input, "\n");

    var acc: i64 = 0;
    var idx: i64 = 0;

    while (lines.next()) |line| : (idx += 1) {
        if (line.len == 0) {
            continue;
        }
        acc += findFirstWordDigit(line) * 10 + findLastWordDigit(line);
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var result = try day1();
    const p1_time = timer.lap();
    std.debug.print("day1 p1: {} in {}ns\n", .{ result, p1_time });
    result = try day1p2();
    const p2_time = timer.read();
    std.debug.print("day1 p2: {} in {}ns\n", .{ result, p2_time });
}
