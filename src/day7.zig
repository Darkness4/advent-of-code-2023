const std = @import("std");

var input = @embedFile("day7.txt");
var input_test = @embedFile("day7_test.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn charToValue(c: u8) u8 {
    return switch (c) {
        '2'...'9' => c - '2',
        'T' => 8,
        'J' => 9,
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

const Hand = struct {
    bid: usize,

    hand: [5]u8,

    // 6: five_of_a_kind
    // 5: four_of_a_kind
    // 4: full_house
    // 3: three_of_a_kind
    // 2: two_pair
    // 1: one_pair
    // 0: high card
    hand_type: i64,
};

fn compareHand(context: void, a: Hand, b: Hand) std.math.Order {
    _ = context;
    if (a.hand_type > b.hand_type) {
        return std.math.Order.gt;
    } else if (a.hand_type < b.hand_type) {
        return std.math.Order.lt;
    }

    for (a.hand, b.hand) |acard, bcard| {
        if (acard > bcard) {
            return std.math.Order.gt;
        } else if (acard < bcard) {
            return std.math.Order.lt;
        }
    }

    // Equality is not allowed
    unreachable;
}

fn textToHand(text: []const u8) !Hand {
    const bid = try std.fmt.parseInt(usize, text[6..], 10);

    // No need for a full hashmap.
    var counts = [_]u8{0} ** 13;
    var parsed_hand = [_]u8{0} ** 5;
    var typ: i64 = 0;
    for (text[0..5], &parsed_hand) |c, *card| {
        const v = charToValue(c);
        counts[v] += 1;
        card.* = v;
    }

    for (counts) |count| {
        typ = switch (count) {
            2 => switch (typ) {
                1 => 2, // Has already a pair
                3 => 4, // Has already a triple
                else => 1,
            },
            3 => switch (typ) {
                1 => 4, // Has already a pair
                else => 3,
            },
            4 => 5,
            5 => 6,
            else => typ,
        };
    }

    return .{
        .bid = bid,
        .hand_type = typ,
        .hand = parsed_hand,
    };
}

fn day7(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");

    var pq = std.PriorityQueue(
        Hand,
        void,
        compareHand,
    ).init(allocator, {});
    defer pq.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const hand = try textToHand(line);
        try pq.add(hand);
    }

    var acc: usize = 0;
    var multiplier: usize = 1;
    while (pq.removeOrNull()) |hand| : (multiplier += 1) {
        acc += hand.bid * multiplier;
    }

    return acc;
}

fn charToValue2(c: u8) u8 {
    return switch (c) {
        'J' => 0,
        '2'...'9' => c - '1',
        'T' => 9,
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

fn textToHand2(text: []const u8) !Hand {
    const bid = try std.fmt.parseInt(usize, text[6..], 10);

    // No need for a full hashmap.
    var counts = [_]u8{0} ** 13;
    var parsed_hand = [_]u8{0} ** 5;
    var typ: i64 = 0;
    var jokers: u8 = 0;
    for (text[0..5], &parsed_hand) |c, *card| {
        const v = charToValue2(c);
        if (v == 0) {
            jokers += 1;
        }
        counts[v] += 1;
        card.* = v;
    }

    for (counts) |count| {
        typ = switch (count) {
            2 => switch (typ) {
                1 => 2, // Has already a pair
                3 => 4, // Has already a triple
                else => 1,
            },
            3 => switch (typ) {
                1 => 4, // Has already a pair
                else => 3,
            },
            4 => 5,
            5 => 6,
            else => typ,
        };
    }

    // Upgrade type by joker
    typ = switch (jokers) {
        1 => switch (typ) {
            0 => 1, // 1J + 1X + any become 2X + any.
            1 => 3, // 1J + 2X + any become 3X + any.
            2 => 4, // 1J + 2X + 2Y become 3X + 2Y.
            3 => 5, // 1J + 3X + 1Y become 4X + 1Y.
            5 => 6, // 1J + 4X become 5X.
            // 4 => unreachable,
            else => typ,
        },
        2 => switch (typ) {
            1 => 3, // 2J+1X+1Y+1Z become 3X+1Y+1Z.
            2 => 5, // 2J+2X+1Y become 4X+1Y.
            4 => 6, // 2J+3X become 5X.
            // 0 => unreachable,
            // 3 => unreachable,
            // 5 => unreachable,
            else => typ,
        },
        3 => switch (typ) {
            3 => 5, // 3J become 4X+1Y.
            4 => 6, // 3J+2X become 5X.
            // 0 => unreachable,
            // 1 => unreachable,
            // 2 => unreachable,
            // 5 => unreachable,
            else => typ,
        },
        4 => 6, // 4J become 5X.
        else => typ, // 5J or 0J
    };

    return .{
        .bid = bid,
        .hand_type = typ,
        .hand = parsed_hand,
    };
}

fn day7p2(data: []const u8) !usize {
    var lines = std.mem.splitSequence(u8, data, "\n");

    var pq = std.PriorityQueue(
        Hand,
        void,
        compareHand,
    ).init(allocator, {});
    defer pq.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const hand = try textToHand2(line);
        try pq.add(hand);
    }

    var acc: usize = 0;
    var multiplier: usize = 1;
    while (pq.removeOrNull()) |hand| : (multiplier += 1) {
        acc += hand.bid * multiplier;
    }

    return acc;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day7(input);
    const p1_time = timer.lap();
    const result_p2 = try day7p2(input);
    const p2_time = timer.read();
    std.debug.print("day7 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day7 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day7" {
    const result = try day7(input_test);
    try std.testing.expect(result == 6440);
}

test "day7p2" {
    const result = try day7p2(input_test);
    try std.testing.expect(result == 5905);
}
