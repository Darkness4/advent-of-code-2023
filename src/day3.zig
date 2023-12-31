const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var input = @embedFile("day3.txt");
var input_test = @embedFile("day3_test.txt");

fn isSymbol(ch: u8) bool {
    return switch (ch) {
        // Number are not symbols
        '0'...'9' => false,
        '.' => false,
        else => true,
    };
}

fn day3(data: []const u8) !i64 {
    var it = std.mem.splitSequence(u8, data, "\n");
    var list = try std.ArrayList([]const u8).initCapacity(allocator, 150);
    defer list.deinit();

    var acc: i64 = 0;

    // Store in array, so we can get a 2D vision.
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try list.append(line);
    }

    for (0.., list.items) |line_index, line| {
        // Number builder
        var num: i64 = 0;
        var num_begin_index: usize = 0;
        var num_end_index: usize = 0;

        var char_index: usize = 0;
        char_loop: while (char_index < line.len) : (char_index += 1) {
            const c = line[char_index];

            if (c <= '9' and c >= '0') {
                if (num == 0) {
                    num_begin_index = char_index;
                }
                num_end_index = char_index;
                num = num * 10 + c - '0';
            }

            if (char_index == line.len - 1 or ((c > '9' or c < '0') and num > 0)) { // EOL or not a number
                defer {
                    num = 0;
                    num_begin_index = 0;
                    num_end_index = 0;
                }

                // Number is built, check surroudings
                const before_num_begin_index = @subWithOverflow(num_begin_index, 1);
                const prev_line_index = @subWithOverflow(line_index, 1);
                if (before_num_begin_index[1] == 0 and isSymbol(line[before_num_begin_index[0]])) { // Check underflow
                    // Check left side
                    acc += num;
                    continue :char_loop;
                }

                if (num_end_index + 1 < line.len and isSymbol(line[num_end_index + 1])) {
                    // Check right side
                    acc += num;
                    continue :char_loop;
                }

                if (line_index + 1 < list.items.len) {
                    // Check bottom
                    const next_line = list.items[line_index + 1];
                    var offset: usize = 1;
                    if (before_num_begin_index[1] == 1) { // If underflow, do not offset
                        offset = 0;
                    }
                    for (num_begin_index - offset..num_end_index + 1 + 1) |i| {
                        if (i < next_line.len and isSymbol(next_line[i])) {
                            acc += num;
                            continue :char_loop;
                        }
                    }
                }

                if (prev_line_index[1] == 0) { // Check underflow
                    // Check top
                    const prev_line = list.items[line_index - 1];
                    var offset: usize = 1;
                    if (before_num_begin_index[1] == 1) { // If underflow, do not offset
                        offset = 0;
                    }
                    for (num_begin_index - offset..num_end_index + 1 + 1) |i| { // +1 +1 because zig range are end exclusive
                        if (i < prev_line.len and isSymbol(prev_line[i])) {
                            acc += num;
                            continue :char_loop;
                        }
                    }
                }
            }
        }
    }

    return acc;
}

const SymbolRef = struct { acc: i64, count: i64 };

fn day3p2(data: []const u8) !i64 {
    var it = std.mem.splitSequence(u8, data, "\n");
    var list = try std.ArrayList([]const u8).initCapacity(allocator, 150);
    defer list.deinit();

    var acc: i64 = 0;

    // Store in array, so we can get a 2D vision.
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try list.append(line);
    }

    // Symbols ref counter
    var symbols = std.AutoHashMap(
        [2]usize,
        SymbolRef,
    ).init(allocator);
    defer symbols.deinit();

    for (0.., list.items) |line_index, line| {
        // Number builder
        var num: i64 = 0;
        var num_begin_index: usize = 0;
        var num_end_index: usize = 0;

        var char_index: usize = 0;
        char_loop: while (char_index < line.len) : (char_index += 1) {
            const c = line[char_index];

            if (c <= '9' and c >= '0') {
                if (num == 0) {
                    num_begin_index = char_index;
                }
                num_end_index = char_index;
                num = num * 10 + c - '0';
            }

            if (char_index == line.len - 1 or ((c > '9' or c < '0') and num > 0)) {
                defer {
                    num = 0;
                    num_begin_index = 0;
                    num_end_index = 0;
                }

                // Number is built, check surroudings
                const before_num_begin_index = @subWithOverflow(num_begin_index, 1);
                const prev_line_index = @subWithOverflow(line_index, 1);
                if (before_num_begin_index[1] == 0 and line[before_num_begin_index[0]] == '*') { // Check underflow
                    const v = try symbols.getOrPut(.{ before_num_begin_index[0], line_index });
                    if (!v.found_existing) {
                        v.value_ptr.* = .{
                            .count = 1,
                            .acc = num,
                        };
                    } else {
                        v.value_ptr.*.count += 1;
                        v.value_ptr.*.acc *= num;
                    }
                    continue :char_loop;
                }

                if (num_end_index + 1 < line.len and line[num_end_index + 1] == '*') {
                    const v = try symbols.getOrPut(.{ num_end_index + 1, line_index });
                    if (!v.found_existing) {
                        v.value_ptr.* = .{
                            .count = 1,
                            .acc = num,
                        };
                    } else {
                        v.value_ptr.*.count += 1;
                        v.value_ptr.*.acc *= num;
                    }
                    continue :char_loop;
                }

                if (line_index + 1 < list.items.len) {
                    // Check bottom
                    const next_line = list.items[line_index + 1];
                    var offset: usize = 1;
                    if (before_num_begin_index[1] == 1) { // If underflow, do not offset
                        offset = 0;
                    }
                    for (num_begin_index - offset..num_end_index + 1 + 1) |i| {
                        if (i < next_line.len and next_line[i] == '*') {
                            const v = try symbols.getOrPut(.{ i, line_index + 1 });
                            if (!v.found_existing) {
                                v.value_ptr.* = .{
                                    .count = 1,
                                    .acc = num,
                                };
                            } else {
                                v.value_ptr.*.count += 1;
                                v.value_ptr.*.acc *= num;
                            }
                            continue :char_loop;
                        }
                    }
                }

                if (prev_line_index[1] == 0) { // Check underflow
                    // Check top
                    const prev_line = list.items[line_index - 1];
                    var offset: usize = 1;
                    if (before_num_begin_index[1] == 1) { // If underflow, do not offset
                        offset = 0;
                    }
                    for (num_begin_index - offset..num_end_index + 1 + 1) |i| { // +1 +1 because zig range are end exclusive
                        if (i < prev_line.len and prev_line[i] == '*') {
                            const v = try symbols.getOrPut(.{ i, line_index - 1 });
                            if (!v.found_existing) {
                                v.value_ptr.* = .{
                                    .count = 1,
                                    .acc = num,
                                };
                            } else {
                                v.value_ptr.*.count += 1;
                                v.value_ptr.*.acc *= num;
                            }
                            continue :char_loop;
                        }
                    }
                }
            }
        }
    }

    // Find '*' with 2 counts
    var symbolsit = symbols.iterator();
    while (symbolsit.next()) |entry| {
        if (entry.value_ptr.count == 2) {
            acc += entry.value_ptr.acc;
        }
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day3(input);
    const p1_time = timer.lap();
    const result_p2 = try day3p2(input);
    const p2_time = timer.read();
    std.debug.print("day3 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day3 p2: {} in {}ns\n", .{ result_p2, p2_time });
}
test "day3" {
    const result = try day3(input_test);
    try std.testing.expect(result == 4361);
}

test "day3p2" {
    const result = try day3p2(input_test);
    try std.testing.expect(result == 467835);
}
