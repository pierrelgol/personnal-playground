const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const file_path = b.option([]const u8, "file_path", "file to read");
    const option = b.addOptions();
    option.addOption(@TypeOf(file_path), "maybe_file_path", file_path);

    const exe = b.addExecutable(.{
        .name = "map_word",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addOptions("option", option);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.addArg("/home/pollivie/workspace/experiment/test.txt");
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
