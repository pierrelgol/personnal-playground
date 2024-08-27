const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const check = b.addStaticLibrary(.{
        .name = "a-star",
        .root_source_file = b.path("src/astar.zig"),
        .target = target,
        .optimize = optimize,
        // .use_llvm = false,
        // .use_lld = false,
    });
    const check_step = b.step("check", "check the codes for errors");
    check_step.dependOn(&check.step);

    const lib = b.addStaticLibrary(.{
        .name = "a-star",
        .root_source_file = b.path("src/astar.zig"),
        .target = target,
        .optimize = optimize,
        // .use_llvm = false,
        // .use_lld = false,
    });
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/astar.zig"),
        .target = target,
        .optimize = optimize,
        // .use_llvm = false,
        // .use_lld = false,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
