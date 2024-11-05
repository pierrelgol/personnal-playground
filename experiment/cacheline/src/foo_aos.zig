const std = @import("std");
const BoundedArray = std.BoundedArray;

pub fn FooAos(comptime T: type) type {
    return struct {
        const Self = @This();
        padding: T = 0,
        alive: bool = true,

        pub fn init(comptime N: usize) !BoundedArray(@This(), N) {
            return try BoundedArray(Self, N).init(N);
        }
    };
}

pub fn main() !void {
    const LEN = 8192;
    const foo_aos = try FooAos(u120).init(LEN);
    const foo_slice = foo_aos.slice();

    for (0..100_000) |_| {
        for (foo_slice) |foo| {
            std.mem.doNotOptimizeAway(foo.alive);
        }
    }
}
