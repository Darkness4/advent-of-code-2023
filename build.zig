const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const days = [_][]const u8{
        "day1",
        "day2",
        "day3",
        "day4",
    };

    const all_run = b.step("all", "Run all");

    var buf: [24]u8 = undefined;
    for (days) |day| {
        const day_exe = b.addExecutable(.{
            .name = day,
            .root_source_file = .{ .path = try std.fmt.bufPrint(&buf, "src/{s}.zig", .{day}) },
            .target = target,
            .optimize = optimize,
        });
        const day_run = b.step(day, try std.fmt.bufPrint(&buf, "Run {s}", .{day}));
        b.installArtifact(day_exe);
        day_run.dependOn(&(b.addRunArtifact(day_exe)).step);
        all_run.dependOn(&(b.addRunArtifact(day_exe)).step);
    }
}
