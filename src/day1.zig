const std = @import("std");

var input = @embedFile("day1.txt");

fn findFirstDigit(data: []const u8) u8 {
    for (data) |char| {
        if (char >= '0' and char < '9') {
            return char - '0';
        }
    }
    return 0;
}

fn findLastDigit(data: []const u8) u8 {
    var ch: u8 = 0;
    for (data) |char| {
        if (char >= '0' and char < '9') {
            ch = char - '0';
        }
    }
    return ch;
}

fn day1() !i64 {
    var lines = std.mem.split(u8, input, "\n");

    var acc: i64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const n = findFirstDigit(line) * 10 + findLastDigit(line);
        acc += n;
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

// P2
fn findFirstWordDigit(data: []const u8) u8 {
    for (0.., data) |i, char| {
        // Is Int
        if (char < '9' and char >= '0') {
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
        if (char < '9' and char >= '0') {
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
    var lines = std.mem.split(u8, input, "\n");

    var acc: i64 = 0;
    var idx: i64 = 0;

    while (lines.next()) |line| {
        defer idx += 1;
        if (line.len == 0) {
            continue;
        }
        const n = findFirstWordDigit(line) * 10 + findLastWordDigit(line);
        if (idx == 0) {
            std.debug.assert(n == 28);
        } else if (idx == 1) {
            std.debug.assert(n == 85);
        } else if (idx == 2) {
            std.debug.assert(n == 18);
        }
        acc += n;
    }

    return acc;
}

const expect = std.testing.expect;

pub fn main() !void {
    var result = try day1();
    std.debug.print("{}\n", .{result});
    result = try day1p2();
    std.debug.print("{}\n", .{result});
}
