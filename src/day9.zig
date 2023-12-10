const std = @import("std");

var input = @embedFile("day9.txt");
var input_test = @embedFile("day9_test.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// Optimized arrays via hard-coded length buffers. Adapted from the data.
const max_lines = 200;
const max_data = 21;

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
fn computeLagrangeBasis(n: usize) ![]i64 {
    const n_i64 = @as(i64, @intCast(n));

    // l_0(n+1) = binom(n+1, 0) * (-1)^n
    //          = (-1)^n
    // Negative when n is impair.
    var l = try std.ArrayList(i64).initCapacity(allocator, n + 1);
    var last: i64 = if (n % 2 == 0) 1 else -1;
    l.appendAssumeCapacity(last);
    for (1..n + 1) |j| {
        const j_i64 = @as(i64, @intCast(j));
        last = -@divExact(last * (n_i64 - j_i64 + 2), j_i64);
        l.appendAssumeCapacity(last);
    }
    return l.toOwnedSlice();
}

fn lagrangeZigNative(data: [max_lines][max_data]i64, n_lines: usize, lagrange_basis: []i64, n: usize, reverse: bool) i64 {
    var acc: i64 = 0;

    if (!reverse) {
        for (0..n + 1) |j| {
            for (0..n_lines) |i| {
                acc += data[i][j] * lagrange_basis[j];
            }
        }
    } else {
        for (0..n + 1) |j| {
            for (0..n_lines) |i| {
                acc += data[i][n - j] * lagrange_basis[j];
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
    // Store matrices.
    var matrix = [_][max_data]i64{[_]i64{0} ** max_data} ** max_lines;
    var x: usize = 0;
    var y: usize = 0;
    var n: usize = 0;

    var number_builder: i64 = 0;
    var negative: bool = false;
    for (data) |c| {
        switch (c) {
            '0'...'9' => number_builder = number_builder * 10 + c - '0',
            '-' => negative = true,
            ' ' => {
                if (negative) number_builder = -number_builder;
                matrix[x][y] = number_builder;
                negative = false;
                number_builder = 0;
                y += 1;
            },
            '\n' => {
                if (y == 0) {
                    continue;
                }
                if (negative) number_builder = -number_builder;
                matrix[x][y] = number_builder;
                negative = false;
                number_builder = 0;
                n = y;
                y = 0;
                x += 1;
            },
            else => unreachable, // UB
        }
    }

    const l = try computeLagrangeBasis(n); // y = n = length of data
    const res = lagrangeZigNative(matrix, x, l, n, false);
    // std.debug.print("l={any} res={} x={}\n", .{ l, res, x });
    return res;
}

fn day9p2(data: []const u8) !i64 {
    // Store matrices.
    var matrix = [_][max_data]i64{[_]i64{0} ** max_data} ** max_lines;
    var x: usize = 0;
    var y: usize = 0;
    var n: usize = 0;

    var number_builder: i64 = 0;
    var negative: bool = false;
    for (data) |c| {
        switch (c) {
            '0'...'9' => number_builder = number_builder * 10 + c - '0',
            '-' => negative = true,
            ' ' => {
                if (negative) number_builder = -number_builder;
                matrix[x][y] = number_builder;
                negative = false;
                number_builder = 0;
                y += 1;
            },
            '\n' => {
                if (y == 0) {
                    continue;
                }
                if (negative) number_builder = -number_builder;
                matrix[x][y] = number_builder;
                negative = false;
                number_builder = 0;
                n = y;
                y = 0;
                x += 1;
            },
            else => {},
        }
    }

    const l = try computeLagrangeBasis(n); // y = n = length of data
    const res = lagrangeZigNative(matrix, x, l, n, true);
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
