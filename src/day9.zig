const std = @import("std");

var input = @embedFile("day9.txt");
var input_test = @embedFile("day9_test.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

/// For a set of n+1 points {(x_0, f(x_0)), ..., (x_n, f(x_n)}
/// Lagrange interpolating polynomial is defined as:
///
///    L(x) = sum[from=j=0,to=n]f(x_j)l_j(x)
///         = sum[from=j=0,to=n]( f(x_j) * prod[from=k=0,to=n,k!=j]((x - x_k)/(x_j - x_k)) )
///
/// x being the value we want to predict.
///
///    l_j(x) = prod[from=k=0,to=n,k!=j]((x - x_k)/(x_j - x_k))
///
/// Knowing that: x_j = j, (j = 0, ..., n):
/// We can heavily simplify the Lagrange basis l_j(x):
///
///        prod[from=k=0,to=n,k!=j]((x - x_k)/(x_j - x_k))
///    <=> prod[from=k=0,to=n,k!=j]((x - k)/(j - k))
///    // Extracting numerator:
///    <=> (prod[from=k=0,to=n](x - k))/(x - j) * prod[from=k=0,to=n,k!=j](1/(j - k))
///    // Extract factorials:
///    <=> (prod[from=k=0,to=n](x - k))/(x - j) * 1/(j! * (-1)^(n-j) * (n - j)!)
///    // Climb (-1)^(n-j):
///    <=> (prod[from=k=0,to=n](x - k))/(x - j) * (-1)^(n-j)/(j! * (n - j)!)
///
/// Knowing that we're looking for x=n+1
///
///     => (prod[from=k=0,to=n](n + 1 - k))/(n + 1 - j) * ((-1)^(n-j))/(j! * (n - j)!)
///    // Put prod into factorial:
///    <=> (n + 1)!/(n + 1 - j) * ((-1)^(n-j))/(j! * (n - j)!)
///    // Group all factorials:
///      = (n + 1)!/(j!(n - j)!(n - j + 1)) * (-1)^(n-j)
///    // (n - j)!(n - j + 1) <=> (n + 1 - j)!
///      = (n + 1)!/(j!(n + 1 - j)!) * (-1)^(n-j)
///      = binom(n+1, j) * (-1)^(n-j)
///
/// Now to compute easily, let's use the recurrent sequence (j is the index):
///
///    l_j+1(n+1) = binom(n+1, j+1) * (-1)^(n-j-1)
///               = - (n+1)!/[(j+1)!(n-j)!] * (-1)^(n-j)
///               // Extract j+1, and multiply by (n-j+1)/(n-j+1)
///               = - (n+1)!/[j!(n-j+1)!] * (-1)^(n-j) * (n-j+1)/(j+1)
///               = - l_j(n+1) * (n-j+1)/(j+1)
///    l_j+1(n+1) = - l_j-1(n+1) * (n-j+2)/j
fn computeLagrangeBasis(data: []i64) ![]i64 {
    const n = data.len - 1;
    const n_i64 = @as(i64, @intCast(n));

    // l_0(n+1) = binom(n+1, 0) * (-1)^n
    //          = (-1)^n
    // Negative when n is impair.
    var l = try std.ArrayList(i64).initCapacity(allocator, data.len);
    var last: i64 = if (n % 2 == 0) 1 else -1;
    l.appendAssumeCapacity(last);
    for (1..data.len) |j| {
        const j_i64 = @as(i64, @intCast(j));
        last = -@divExact(last * (n_i64 - j_i64 + 2), j_i64);
        l.appendAssumeCapacity(last);
    }
    return l.toOwnedSlice();
}

fn lagrangeZigNative(data: [][]i64, lagrange_basis: []i64, reverse: bool) i64 {
    var acc: i64 = 0;

    if (!reverse) {
        for (0.., lagrange_basis) |i, l| {
            for (data) |line| {
                acc += line[i] * l;
            }
        }
    } else {
        for (0.., lagrange_basis) |i, l| {
            for (data) |line| {
                acc += line[line.len - i - 1] * l;
            }
        }
    }

    return acc;
}

// day9 won't be zig native, let's use lagrange interpolation with simd libraries.
// We've got a matrix, let's do it for funsies, especially since Zig is a low-level language.
// TODO: OpenBLAS maybe.
// TODO: Better parsing and don't cheat.
fn day9(data: []const u8) !i64 {
    var lines = std.mem.splitSequence(u8, data, "\n");

    // Store matrices.
    var matrix_list = try std.ArrayList([]i64).initCapacity(allocator, 300);
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var line_parser = try std.ArrayList(i64).initCapacity(allocator, 300);
        var vals = std.mem.splitSequence(u8, line, " ");
        while (vals.next()) |v| {
            line_parser.appendAssumeCapacity(try std.fmt.parseInt(i64, v, 10));
        }
        matrix_list.appendAssumeCapacity(try line_parser.toOwnedSlice());
    }
    const matrix = try matrix_list.toOwnedSlice();

    const l = try computeLagrangeBasis(matrix[0]);
    const res = lagrangeZigNative(matrix, l, false);
    return res;
}

fn day9p2(data: []const u8) !i64 {
    var lines = std.mem.splitSequence(u8, data, "\n");

    // Store matrices.
    var matrix_list = try std.ArrayList([]i64).initCapacity(allocator, 300);
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var line_parser = try std.ArrayList(i64).initCapacity(allocator, 300);
        var vals = std.mem.splitSequence(u8, line, " ");
        while (vals.next()) |v| {
            line_parser.appendAssumeCapacity(try std.fmt.parseInt(i64, v, 10));
        }
        matrix_list.appendAssumeCapacity(try line_parser.toOwnedSlice());
    }
    const matrix = try matrix_list.toOwnedSlice();

    const l = try computeLagrangeBasis(matrix[0]);
    const res = lagrangeZigNative(matrix, l, true);
    return res;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const result_p1 = try day9(input);
    const p1_time = timer.lap();

    const result_p2 = try day9p2(input);
    const p2_time = timer.read();
    std.debug.print("day9 p1: {} in {}ns\n", .{ result_p1, p1_time });
    std.debug.print("day9 p2: {} in {}ns\n", .{ result_p2, p2_time });
}

test "day9" {
    const result = try day9(input_test);
    try std.testing.expect(result == 114);
}

test "day9p2" {
    const result = try day9p2(input_test);
    try std.testing.expect(result == 2);
}
