const std = @import("std");
const BoundedArray = std.BoundedArray;

pub fn FooSoa(comptime T: type, comptime N: usize) type {
    return struct {
        paddings: BoundedArray(T, N),
        alives: BoundedArray(bool, N),

        pub fn init() !@This() {
            return .{
                .alives = try BoundedArray(bool, N).init(N),
                .paddings = try BoundedArray(T, N).init(N),
            };
        }
    };
}

pub fn main() !void {
    const LEN = 8192;
    const foo_soa = try FooSoa(u120, LEN).init();
    const alives = foo_soa.alives.slice();

    for (0..100_000) |_| {
        for (alives) |foo| {
            std.mem.doNotOptimizeAway(foo);
        }
    }
}
