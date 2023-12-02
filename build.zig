const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const day1 = b.addExecutable(.{
        .name = "day1",
        .root_source_file = .{ .path = "src/day1.zig" },
        .target = target,
        .optimize = optimize,
    });
    const day2 = b.addExecutable(.{
        .name = "day2",
        .root_source_file = .{ .path = "src/day2.zig" },
        .target = target,
        .optimize = optimize,
    });

    const day1_run = b.step("day1", "Run day1");
    day1_run.dependOn(&(b.addRunArtifact(day1)).step);

    const day2_run = b.step("day2", "Run day2");
    day2_run.dependOn(&(b.addRunArtifact(day2)).step);
}
