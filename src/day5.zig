const std = @import("std");

var input = @embedFile("day5.txt");
var input_test = @embedFile("day5_test.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const ValueWithCounter = struct { v: i64, counter: i64 };

fn day5(data: []const u8) !i64 {
    var lines = std.mem.splitSequence(u8, data, "\n");

    // Parse seeds
    const seeds_line = lines.next().?;
    const sep_idx = std.mem.indexOf(u8, seeds_line, ":").?;
    var seeds_it = std.mem.splitSequence(u8, seeds_line[sep_idx + 2 ..], " ");

    // Store in array
    var list = try std.ArrayList(ValueWithCounter).initCapacity(allocator, 150);
    defer list.deinit();
    while (seeds_it.next()) |seed| {
        const v = try std.fmt.parseInt(i64, seed, 10);
        try list.append(.{ .v = v, .counter = 0 });
    }

    // Start mapping
    var round: i64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) { // New section
            continue;
        }
        if (line[0] < '0' or line[0] > '9') { // New section
            round += 1;
            continue;
        }
        // std.debug.print("round {}\n", .{round});

        // We assume that maps are sorted seed->soil->fertilizer->water->light->temp->hum->location
        // Parsing
        var it = std.mem.splitSequence(u8, line, " ");
        const dst_start = try std.fmt.parseInt(i64, it.next().?, 10);
        const src_start = try std.fmt.parseInt(i64, it.next().?, 10);
        const length = try std.fmt.parseInt(i64, it.next().?, 10);

        // Loop over array
        for (list.items) |*vcounter| {
            // Map if in range
            if (vcounter.*.counter != round and vcounter.*.v >= src_start and vcounter.*.v < src_start + length) {
                // std.debug.print("{} -> {}\n", .{ vcounter.*.v, vcounter.*.v + dst_start - src_start });
                vcounter.*.v += dst_start - src_start;
                vcounter.*.counter = round;
            }
        }
    }

    var min: i64 = std.math.maxInt(i64);
    for (list.items) |*vcounter| {
        min = @min(min, vcounter.*.v);
    }

    return min;
}

const Range = struct { start: usize, length: usize };

fn day5p2(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");

    // Parse seeds
    const seeds_line = lines.next().?;
    const sep_idx = std.mem.indexOf(u8, seeds_line, ":").?;
    var range_it = std.mem.splitSequence(u8, seeds_line[sep_idx + 2 ..], " ");

    // Store in array
    var list = try std.ArrayList(Range).initCapacity(allocator, 1000);
    defer list.deinit();
    while (range_it.next()) |start| {
        const v = try std.fmt.parseInt(usize, start, 10);
        const length = try std.fmt.parseInt(usize, range_it.next().?, 10);
        try list.append(.{ .start = v, .length = length });
    }

    // Start mapping
    // var round: i64 = 0;
    var new_list = try std.ArrayList(Range).initCapacity(allocator, 1000);
    defer new_list.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) { // New section
            continue;
        }
        if (line[0] < '0' or line[0] > '9') { // New section
            // round += 1;
            // Pass mapped items to list. Left overs are still present inside list.
            try list.appendSlice(new_list.items);
            new_list.clearRetainingCapacity();
            continue;
        }

        // We assume that maps are sorted seed->soil->fertilizer->water->light->temp->hum->location
        // Parsing
        var it = std.mem.splitSequence(u8, line, " ");
        const dst_start = try std.fmt.parseInt(usize, it.next().?, 10);
        const src_start = try std.fmt.parseInt(usize, it.next().?, 10);
        const length = try std.fmt.parseInt(usize, it.next().?, 10);

        // Loop over array
        var idx: usize = 0;
        var replay_offset: usize = 0; // Is 1 when an element is ejected (no under not overflow).

        // Ensure capacity. We do not allow pointer invalidation from this point due to looping dynamically.
        // There is possibly (len(items) * 2) due to one append.
        try list.ensureTotalCapacity(list.items.len * 2);
        while (idx < list.items.len) : ({
            idx += 1 - replay_offset;
            replay_offset = 0;
        }) {
            const range = &list.items[idx];
            // std.debug.print("handling {}-{}, rule {} {} {}\n", .{ range.*.start, range.*.start + range.*.length, dst_start, src_start, length });
            // If outside
            if (range.*.start > src_start + length or range.*.start + range.*.length < src_start) {
                continue; // Not mapped
            }
            var underflow: bool = false;
            var overflow: bool = false;
            var low = range.*.start;
            // If underflow
            if (range.*.start < src_start) {
                low = src_start;
                underflow = true;
            }
            // If overflow
            var high = range.*.start + range.*.length;
            if (range.*.start + range.*.length > src_start + length) {
                high = src_start + length;
                overflow = true;
            }
            const new_length = high - low;

            // Add mapped part
            try new_list.append(.{ .start = low + dst_start - src_start, .length = new_length });
            // std.debug.print("{}-{} -> {}-{} (len: {})\n", .{ low, high, low + dst_start - src_start, high + dst_start - src_start, new_length });

            if (underflow and overflow) {
                // Add overflow part
                list.appendAssumeCapacity(.{ .start = high, .length = range.*.length - new_length });
                // Adjust original range without realloc (this is the lower part that has underflowed)
                range.*.length -= new_length;
            } else if (underflow) {
                range.*.length -= new_length;
            } else if (overflow) {
                range.*.start = high;
                range.*.length -= new_length;
            } else if (!underflow and !overflow) {
                // Eject because we don't need to remap it for the next line.
                _ = list.swapRemove(idx);
                replay_offset = 1;
            }
        }
    }

    try list.appendSlice(new_list.items);
    var min: usize = std.math.maxInt(usize);
    for (list.items) |*range| {
        min = @min(min, range.*.start);
    }

    return min;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day5(input);
    const p1_time = timer.lap();
    const result_p2 = try day5p2(input);
    const p2_time = timer.read();
    std.debug.print("day5 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day5 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day5" {
    const result = try day5(input_test);
    try std.testing.expect(result == 35);
}

test "day5p2" {
    const result = try day5p2(input_test);
    try std.testing.expect(result == 46);
}
