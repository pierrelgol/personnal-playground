const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const heap = std.heap;
const process = std.process;
const AllocatorError = mem.Allocator.Error;
const Allocator = mem.Allocator;
const ArgIterator = process.ArgIterator;
const Parser = @import("parser.zig").Parser;
const puz = @import("puzzle.zig");
const search = @import("search.zig");
const NodePool = @import("node.zig").AstarNodePoolUnmanaged;

comptime {
    std.testing.refAllDeclsRecursive(Parser);
}

pub fn main() !void {
    const page_allocator = heap.page_allocator;
    var arena = heap.ArenaAllocator.init(page_allocator);
    errdefer arena.deinit();

    const allocator = arena.allocator();

    var args_iter = process.argsWithAllocator(allocator) catch |e| switch (e) {
        error.OutOfMemory => {
            std.log.err("Encountered fatal error : {any}", .{e});
            process.exit(@intFromError(error.OutOfMemory));
        },
    };
    errdefer args_iter.deinit();

    if (args_iter.skip() != true) {
        std.log.err("Encountered fatal error : missing file argument", .{});
        process.exit(1);
    }

    const file_path = args_iter.next() orelse unreachable;
    std.log.debug("file_path = [{s}]", .{file_path});

    const cwd = fs.cwd();
    const file = try cwd.openFile(file_path, .{
        .mode = .read_only,
    });
    errdefer file.close();

    const content = try file.readToEndAlloc(allocator, std.math.maxInt(i32));
    errdefer allocator.free(content);
    std.log.debug("file_content = {s}", .{content});

    var config = Parser.init(allocator, content) catch |e| switch (e) {
        error.OutOfMemory => {
            std.log.err("Encountered fatal error : {any}", .{e});
            process.exit(@intFromError(error.OutOfMemory));
        },
        error.MissingComment => {
            std.log.err("MissingComment ", .{});
            process.exit(@intFromError(error.MissingComment));
        },
        error.MissingDimension => {
            std.log.err("MissingDimension ", .{});
            process.exit(@intFromError(error.MissingDimension));
        },
        error.MissingContent => {
            std.log.err("MissingContent", .{});
            process.exit(@intFromError(error.MissingContent));
        },
        error.IncorrectConfiguration => {
            std.log.err("IncorrectConfiguration ", .{});
            process.exit(@intFromError(error.IncorrectConfiguration));
        },
        else => {
            std.log.err("Encountered fatal error : {any}", .{e});
            process.exit(1);
        },
    };
    defer config.deinit(allocator);
    try config.display();

    const node = NodePool(u8).AstarNode.init('a', null);
    std.debug.print("{}", .{node});
}
