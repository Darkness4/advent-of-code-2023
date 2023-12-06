const std = @import("std");

var input = @embedFile("day6.txt");
var input_test = @embedFile("day6_test.txt");

fn day6(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");
    var times = std.mem.tokenizeSequence(u8, lines.next().?, " ");
    var record_distances = std.mem.tokenizeSequence(u8, lines.next().?, " ");
    // Ignore headers
    _ = times.next();
    _ = record_distances.next();

    var acc: usize = 1;

    while (times.next()) |time| {
        const t = try std.fmt.parseInt(usize, time, 10);

        const record_distance = try std.fmt.parseInt(usize, record_distances.next().?, 10);

        // distance = f(hold_time, t = time) = hold_time * (t - hold_time)
        // valid_distance => f(hold_time, t = time) = hold_time * (t - hold_time) > record_distance
        // This is a second degree equation. We need to find where f(hold_time, t = time) - record_distance = 0.
        // Normally, the sqrt(delta) would give immediatly the distance between roots.
        // However, integer rounding sucks, so instead we have to do something else.
        // We've already have some roots:
        // f(0, t = time) = 0 and f(time, t = time) = 0;
        // Meaning the highest point is at time/2.
        // Thanks to this we've simply have to find one root and mirror it
        // related to the highest point, so let's binary search it.
        var left: usize = 1; // No need to look at zero
        var right: usize = t / 2; // Look for left side of the curve.
        while (right > left) {
            const hold_time = left + ((right - left) / 2);
            if (hold_time * (t - hold_time) > record_distance) {
                right = hold_time;
            } else {
                left = hold_time + 1;
            }
        }

        // // distance = 2 * (time/2 - right) + 1
        acc *= t - 2 * right + 1;

        // Or we can do ceil(x2) - ceil(x1).
        // const delta: f64 = t * t - 4.0 * (record_distance + 0.5); // We add 0.5, so we get > 0.
        // const x1 = std.math.ceil((t - std.math.sqrt(delta)) / 2.0);
        // const x2 = std.math.ceil((t + std.math.sqrt(delta)) / 2.0);
        // acc *= x2 - x1;
        // Which is slightly slower.
    }

    return acc;
}

fn day6p2(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");
    var times = std.mem.tokenizeSequence(u8, lines.next().?, " ");
    var record_distances = std.mem.tokenizeSequence(u8, lines.next().?, " ");
    // Ignore headers
    _ = times.next();
    _ = record_distances.next();

    var t: usize = 0;
    var record_distance: usize = 0;
    while (times.next()) |time| {
        for (time) |c| {
            if (c >= '0' or c <= '9') {
                t = t * 10 + c - '0';
            }
        }

        const r = record_distances.next().?;
        for (r) |c| {
            if (c >= '0' or c <= '9') {
                record_distance = record_distance * 10 + c - '0';
            }
        }
    }

    var left: usize = 1;
    var right: usize = t / 2;
    while (right > left) {
        const hold_time = left + ((right - left) / 2);
        if (hold_time * (t - hold_time) > record_distance) {
            right = hold_time;
        } else {
            left = hold_time + 1;
        }
    }

    return t - 2 * right + 1;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day6(input);
    const p1_time = timer.lap();
    const result_p2 = try day6p2(input);
    const p2_time = timer.read();
    std.debug.print("day6 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day6 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day6" {
    const result = try day6(input_test);
    std.debug.print("{}\n", .{result});
    try std.testing.expect(result == 288);
}

test "day6p2" {
    const result = try day6p2(input_test);
    try std.testing.expect(result == 71503);
}
