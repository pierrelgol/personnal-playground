const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const foo_aos = b.addExecutable(.{
        .name = "foo_aos",
        .root_source_file = b.path("src/foo_aos.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(foo_aos);

    const foo_soa = b.addExecutable(.{
        .name = "foo_soa",
        .root_source_file = b.path("src/foo_soa.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(foo_soa);
}
