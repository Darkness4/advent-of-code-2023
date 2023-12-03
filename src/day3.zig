const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var input = @embedFile("day3.txt");

fn isSymbol(ch: u8) bool {
    return switch (ch) {
        // Number are not symbols
        '0'...'9' => false,
        '.' => false,
        else => true,
    };
}

fn day3() !i64 {
    var it = std.mem.splitSequence(u8, input, "\n");
    var list = std.ArrayList([]const u8).init(allocator);

    var acc: i64 = 0;

    // Store in array, so we can get a 2D vision.
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try list.append(line);
    }

    var line_index: usize = 0;
    while (line_index < list.items.len) : (line_index += 1) {
        const line = list.items[line_index];

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
                if (before_num_begin_index[1] == 0 and isSymbol(line[before_num_begin_index[0]])) { // Check underflow
                    // Check left side
                    std.debug.print("left {}\n", .{num});
                    acc += num;
                    continue :char_loop;
                }

                if (num_end_index + 1 < line.len and isSymbol(line[num_end_index + 1])) {
                    // Check right side
                    std.debug.print("right {}\n", .{num});
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
                            std.debug.print("bottom {}\n", .{num});
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
                            std.debug.print("top {}\n", .{num});
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

pub fn main() !void {
    const result = try day3();
    std.debug.print("{}\n", .{result});
}
