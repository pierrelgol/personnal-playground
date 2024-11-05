const std = @import("std");

export fn dump_stack_trace() void {
    std.debug.dumpCurrentStackTrace(null);
}

export fn add_number(a: i32, b: i32) callconv(.C) i32 {
    return (a + b);
}

export fn zig_do() void {}

pub const _start = void;
