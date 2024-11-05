const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_1 = b.addExecutable(.{
        .name = "main_1",
        .root_source_file = b.path("src/main_1.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_1);

    const exe_2 = b.addExecutable(.{
        .name = "main_2",
        .root_source_file = b.path("src/main_2.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_2);

    const exe_3 = b.addExecutable(.{
        .name = "main_3",
        .root_source_file = b.path("src/main_3.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_3);
}
