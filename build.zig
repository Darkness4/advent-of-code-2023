const std = @import("std");

// Learn: https://ziglang.org/learn/build-system/
// Ref: https://ziglang.org/documentation/master/#Zig-Build-System/
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const days = [_][]const u8{
        "day1",
        "day2",
        "day3",
        "day4",
        "day5",
        "day6",
        "day7",
        "day8",
        "day9",
        "day10",
    };

    const test_run = b.step("test", "Run unit tests");
    const all_run = b.step("all", "Run all");

    var buf: [24]u8 = undefined;
    for (days) |day| {
        const day_exe = b.addExecutable(.{
            .name = day,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = try std.fmt.bufPrint(&buf, "src/{s}.zig", .{day}) } },
            .target = target,
            .optimize = optimize,
        });
        const day_run = b.step(day, try std.fmt.bufPrint(&buf, "Run {s}", .{day}));
        b.installArtifact(day_exe);
        day_run.dependOn(&(b.addRunArtifact(day_exe)).step);
        all_run.dependOn(&(b.addRunArtifact(day_exe)).step);

        const day_test = b.addTest(.{
            .name = day,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = try std.fmt.bufPrint(&buf, "src/{s}.zig", .{day}) } },
            .target = target,
            .optimize = optimize,
        });
        test_run.dependOn(&(b.addRunArtifact(day_test)).step);
    }
}
