const std = @import("std");
const opt = @import("option");
const fs = std.fs;
const Allocator = std.mem.Allocator;
const cwd = std.fs.cwd();
const time = std.time;

pub fn Words(alignment: ?u29) type {
    return struct {
        const Self = @This();
        word_list: [][]const u8,
        buf: []align(alignment orelse 1) u8,

        pub fn init(word_list: [][]const u8, buf: []align(alignment orelse 1) u8) Self {
            return .{
                .word_list = word_list,
                .buf = buf,
            };
        }
    };
}

fn isAlpha(word: []const u8) bool {
    for (word) |char| {
        if ((char | 32) >= 'a' and (char | 32) <= 'z') continue else return false;
    }
    return true;
}

fn mapwords(allocator: Allocator, file_path: []const u8) !Words(std.mem.page_size) {
    const file = try cwd.openFile(file_path, .{ .mode = .read_only });
    errdefer file.close();

    const file_stat = try file.stat();
    const file_size = file_stat.size;

    const file_mapping: ?[*]align(std.mem.page_size) u8 = null;
    const content = try std.posix.mmap(file_mapping, file_size, std.posix.PROT.READ, .{ .TYPE = .PRIVATE }, file.handle, 0);
    errdefer std.posix.munmap(content);
    @prefetch(content.ptr, .{
        .rw = .read,
        .locality = 3,
        .cache = .data,
    });

    var word_list = std.ArrayList([]const u8).init(allocator);
    errdefer word_list.deinit();

    var splitIterator = std.mem.splitScalar(u8, content, '\n');
    while (splitIterator.next()) |word| {
        @prefetch(content., .{
            .rw = .read,
            .locality = 3,
            .cache = .data,
        });
        if (isAlpha(word)) {
            try word_list.append(word);
        }
    }
    const words = Words(std.mem.page_size).init(try word_list.toOwnedSlice(), content);
    file.close();
    return words;
}

fn loadWords(allocator: Allocator, file_path: []const u8) !Words(null) {
    const buf = try fs.cwd().readFileAlloc(allocator, file_path, std.math.maxInt(usize));
    var word_list = std.ArrayList([]const u8).init(allocator);

    var splitIterator = std.mem.splitScalar(u8, buf, '\n');
    while (splitIterator.next()) |word| {
        if (isAlpha(word)) {
            try word_list.append(word);
        }
    }
    const words = Words(null).init(try word_list.toOwnedSlice(), buf);
    return words;
}

pub fn main() !void {
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    errdefer arena.deinit();
    const allocator = arena.allocator();
    var args = std.process.args();
    defer args.deinit();
    if (!args.skip()) return;
    const file_name = opt.maybe_file_path orelse args.next() orelse "test.txt";

    // const from_load = try loadWords(allocator, file_name);
    // _ = from_load;
    // arena.deinit();

    const from_map = try mapwords(allocator, file_name);
    defer std.posix.munmap(from_map.buf);
}
