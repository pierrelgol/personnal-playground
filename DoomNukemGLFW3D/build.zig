const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mach_glfw_dep = b.dependency("mach-glfw", .{
        .target = target,
        .optimize = optimize,
    });

    const mach_glfw = mach_glfw_dep.module("mach-glfw");

    const lib = b.addStaticLibrary(.{
        .name = "smlx",
        .root_source_file = b.path("src/smlx.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("mach-glfw", mach_glfw);
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "DoomNukemGLFW3D",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", mach_glfw);
    b.installArtifact(exe);

    const check = b.addExecutable(.{
        .name = "DoomNukemGLFW3D",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", mach_glfw);

    const check_step = b.step("check", "check if code compiles");
    check_step.dependOn(&check.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/smlx.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.root_module.addImport("mach-glfw", mach_glfw);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unit_tests.root_module.addImport("mach-glfw", mach_glfw);
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_lib_unit_tests.step);
}
