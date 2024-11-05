const std = @import("std");
const meta = std.meta;
const print = std.debug.print;

const PrintableTrait = struct {
    pub fn println(_: anytype) void {
        print("hi\n", .{});
    }
};

const ComparableTrait = struct {
    pub fn lessThan(arg1: anytype, arg2: anytype) bool {
        return arg1 < arg2;
    }
};

pub fn FluentComposer(comptime Impls: []const type) type {
    return @Type(.{ .@"struct" = .{ .layout = .auto, .decls = &[0]std.builtin.Type.Declaration{}, .is_tuple = false, .backing_integer = null, .fields = blk: {
        var i: usize = 0;
        var ft: [Impls.len]std.builtin.Type.StructField = undefined;
        for (Impls) |T| {
            const TypeInfo = @typeInfo(T);
            for (TypeInfo.@"struct".decls) |decl| {
                const function = @field(T, decl.name);
                const funtion_pointer = &function;

                ft[i] = std.builtin.Type.StructField{
                    .name = decl.name[0..],
                    .type = *const @TypeOf(function),
                    .default_value = @ptrCast(&funtion_pointer),
                    .is_comptime = false,
                    .alignment = 0,
                };
                i += 1;
            }
        }
        break :blk ft[0..Impls.len];
    } } });
}

pub fn main() !void {
    const FLT = FluentComposer(&[_]type{ PrintableTrait, ComparableTrait }){};
    FLT.println("hi");
    try std.testing.expect(FLT.lessThan(1, 2));
}
