const std = @import("std");

var input = @embedFile("day8.txt");
var input_test = @embedFile("day8_test.txt");
var input_test2 = @embedFile("day8_test2.txt");
var input_test3 = @embedFile("day8_test3.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// Because it is faster to compare int compared to strings
fn base26decode(data: []const u8) usize {
    var result: usize = 0;
    for (data) |c| {
        const v = c - 'A';
        result = result * 26 + @as(usize, v);
    }
    return result;
}

const Node = struct { name: usize, right: usize, left: usize, last_char: u8 };

fn day8(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");

    var nodes = [_]Node{.{
        .name = 0,
        .last_char = 0, // That's for p2.
        .left = 0,
        .right = 0,
    }} ** 17576; // 17575 == ZZZ

    const instructions = lines.next().?;
    _ = lines.next(); // Skip empty line

    // Build tree
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const name = base26decode(line[0..3]);
        nodes[name] = .{
            .name = name,
            .left = base26decode(line[7..10]),
            .right = base26decode(line[12..15]),
            .last_char = 0,
        };
    }

    var acc: usize = 0;
    var node = nodes[0]; // AAA = 0
    outer: while (true) {
        for (instructions) |i| {
            node = switch (i) {
                'R' => nodes[node.right],
                else => nodes[node.left],
            };
            acc += 1;
            if (node.name == 17575) {
                break :outer;
            }
        }
    }

    return acc;
}

fn day8p2(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");

    var nodes = [_]Node{.{
        .name = 0,
        .left = 0,
        .right = 0,
        .last_char = 0,
    }} ** 17576; // 17575 == ZZZ
    var start_nodes = try std.ArrayList(usize).initCapacity(allocator, 676); // 26*26

    const instructions = lines.next().?;
    _ = lines.next(); // Skip empty line

    // Build tree
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const name = base26decode(line[0..3]);
        nodes[name] = .{
            .name = name,
            .left = base26decode(line[7..10]),
            .right = base26decode(line[12..15]),
            .last_char = line[2],
        };
        if (line[2] == 'A') {
            try start_nodes.append(name);
        }
    }
    const start_nodes_slice = try start_nodes.toOwnedSlice();

    // Can't do naively. Find the LCM between path loops.
    // See example (or test3):
    // One has a loop of length 2, the other has a loop of length 3.
    // Multiples of 2: 2, 4, 6 ...
    // Multiple of 3: 3, 6, ...
    // => LCM = 6
    // The LCM of multiple numbers:
    // LCM(a, b) = |a*b|/gcd(a, b)
    // LCM(a_0, ..., a_n) = LCM(...(LCM(a_0, a_1), ...), a_n)
    var lcm: usize = 1;
    for (start_nodes_slice) |node_ref| {
        var node: Node = nodes[node_ref];
        var acc: usize = 0;
        outer: while (true) {
            for (instructions) |i| {
                node = switch (i) {
                    'R' => nodes[node.right],
                    else => nodes[node.left],
                };
                acc += 1;
                if (node.last_char == 'Z') {
                    break :outer;
                }
            }
        }
        lcm *= acc / std.math.gcd(lcm, acc);
    }

    return lcm;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day8(input);
    const p1_time = timer.lap();
    const result_p2 = try day8p2(input);
    const p2_time = timer.read();
    std.debug.print("day8 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day8 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day8" {
    var result = try day8(input_test);
    try std.testing.expect(result == 2);
    result = try day8(input_test2);
    try std.testing.expect(result == 6);
}

test "day8p2" {
    const result = try day8p2(input_test3);
    try std.testing.expect(result == 6);
}
