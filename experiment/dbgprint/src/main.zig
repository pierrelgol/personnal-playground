const std = @import("std");
/// Utility for print-if debugging, a-la Rust's dbg! macro.
///
/// dbg prints the value with the prefix, while also returning the value, which makes it convenient
/// to drop it in the middle of a complex expression.
pub fn dbg(prefix: []const u8, value: anytype) @TypeOf(value) {
    std.debug.print("{s} = {any}\n", .{
        prefix,
        std.json.fmt(value, .{ .whitespace = .indent_4 }),
    });
    return value;
}

pub fn dbg2() !void {
    const info = try std.debug.getSelfDebugInfo();
    try std.debug.errorReturnTraceHelper();
    const out = std.io.getStdErr();
    const tty = std.io.tty.detectConfig(out);
    const addr = @returnAddress();
    try std.debug.printSourceAtAddress(info, out.writer(), addr, tty);
}

pub fn main() !void {
    const bag: Foo = .{ .bar = 5, .baz = 'z' };
    const bad = dbg("assignment", bag);
    _ = bad;
    try dbg2();
}
