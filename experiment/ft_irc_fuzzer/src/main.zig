const std = @import("std");
const ArrayList = std.ArrayList;

const fmt = std.fmt;
const parseInt = fmt.parseInt;
const ParseIntError = fmt.ParseIntError;

const heap = std.heap;
const ArenaAllocator = heap.ArenaAllocator;

const io = std.io;
const stdout = io.getStdOut().writer();
const stderr = io.getStdErr().writer();

const mem = std.mem;
const Allocator = mem.Allocator;
const AllocatorError = mem.Allocator.Error;

const proc = std.process;
const ArgIterator = proc.ArgIterator;
const ArgIteratorError = proc.ArgIterator.InitError;

const posix = std.posix;
const ConnectError = posix.ConnectError;
const SockaddrIn = posix.sockaddr.in;
const Socket = posix.socket_t;
const pollfd = posix.pollfd;

const net = std.net;

pub fn println(comptime format: []const u8, arguments: anytype) void {
    stdout.print(format ++ "\n", arguments) catch unreachable;
}

pub fn eprintln(comptime format: []const u8, arguments: anytype) void {
    stderr.print(format ++ "\n", arguments) catch unreachable;
}

const Client = struct {
    port: u16,
    addr: SockaddrIn,
    sock: Socket,

    pub fn init(allocator: Allocator, port: u16, addr: SockaddrIn) !*Client {
        @breakpoint();
        const client: *Client = try allocator.create(Client);
        var opt: [@sizeOf(posix.sockaddr)]u8 = undefined;
        @memset(opt[0..], 0x0);

        const socket = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, 0);
        _ = try posix.fcntl(socket, posix.F.SETFL, posix.SOCK.NONBLOCK);

        client.* = .{
            .port = port,
            .addr = addr,
            .sock = socket,
        };

        return (client);
    }

    pub fn connect(client: *Client, addr: SockaddrIn) !void {
        try posix.connect(client.sock, @as(*const posix.sockaddr, @ptrCast(&addr)), @sizeOf(posix.sockaddr));
    }

    pub fn send(client: *Client, msg: []const u8) !usize {
        return try posix.send(client.sock, msg, posix.MSG.DONTWAIT);
    }

    pub fn deinit(client: *Client, allocator: Allocator) void {
        posix.close(client.sock);
        allocator.destroy(client);
    }
};

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

const Fuzzer = struct {
    allocator: Allocator,
    agents: ArrayList(*Client),
    fds: ArrayList(posix.pollfd),
    pass: []const u8,
    port: u16,

    pub fn init(allocator: Allocator, port: u16, pass: []const u8) Fuzzer {
        return .{
            .allocator = allocator,
            .port = port,
            .pass = pass,
            .agents = ArrayList(*Client).init(allocator),
            .fds = ArrayList(posix.pollfd).init(allocator),
        };
    }

    pub fn fuzz(fuzzer: *Fuzzer, n_clients: usize) !void {
        const server_addr = try net.Ip4Address.resolveIp("0.0.0.0", fuzzer.port);
        const server_ip = server_addr.sa;
        println("ip : {any}\n", .{server_ip.addr});
        for (0..n_clients) |_| {
            const client = try Client.init(fuzzer.allocator, fuzzer.port, .{
                .family = posix.AF.INET,
                .port = std.mem.nativeToBig(u16, fuzzer.port),
                .addr = 0,
                .zero = [_]u8{0} ** 8,
            });

            client.connect(server_ip) catch {};

            const client_fd: pollfd = .{
                .fd = client.sock,
                .events = posix.POLL.OUT,
                .revents = 0,
            };

            try fuzzer.agents.append(dbg("fuzz", client));
            try fuzzer.fds.append(client_fd);
        }

        var rand = std.Random.DefaultPrng.init(0);

        while (true) {
            _ = posix.poll(fuzzer.fds.items[0..], 2) catch unreachable;

            for (fuzzer.fds.items, 0..) |client_poll, i| {
                if (client_poll.revents == posix.POLL.OUT) {
                    const idx = (rand.next() % 5) + 1;
                    switch (idx) {
                        1 => {
                            _ = try fuzzer.agents.items[i].send("\r\n");
                        },
                        2 => {
                            _ = try fuzzer.agents.items[i].send("PASS password\r\n");
                        },
                        3 => {
                            _ = try fuzzer.agents.items[i].send("NICK\n");
                            _ = try fuzzer.agents.items[i].send(" pollivie\n");
                            _ = try fuzzer.agents.items[i].send("\r\n");
                        },
                        4 => {
                            _ = try fuzzer.agents.items[i].send("PASS\n");
                            _ = try fuzzer.agents.items[i].send("NICK\n");
                        },
                        5 => {
                            _ = try fuzzer.agents.items[i].send("");
                        },
                        else => {
                            continue;
                        },
                    }
                } else continue;
            }
        }
    }

    pub fn deinit(fuzzer: *Fuzzer) void {
        for (fuzzer.agents.items) |agent| {
            agent.deinit(fuzzer.allocator);
        }

        for (fuzzer.fds.items) |fds| {
            posix.close(fds.fd);
        }

        fuzzer.agents.deinit();
        fuzzer.fds.deinit();
    }
};

pub fn main() u8 {
    const backing_allocator = heap.page_allocator;

    var arena = ArenaAllocator.init(backing_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var argv = proc.argsWithAllocator(allocator) catch |err| switch (err) {
        else => {
            eprintln("ircfuzz : encountered fatal {!}", .{err});
            return (@intFromError(err));
        },
    };
    defer argv.deinit();

    if (!argv.skip()) {
        println("ircfuzz : usage\n$> ircfuzz <u16:port> <string:password>", .{});
        return (0);
    }

    const valid_port = argv.next() orelse "0";

    const port = parseInt(u16, valid_port, 10) catch |err| switch (err) {
        ParseIntError.Overflow => {
            eprintln("ircfuzz : port {s} is out of range. [0-65535]\n", .{valid_port});
            return (1);
        },
        ParseIntError.InvalidCharacter => {
            eprintln("ircfuzz : port {s} contains invalid characteres\n", .{valid_port});
            return (1);
        },
    };

    @breakpoint();
    const valid_pass = argv.next() orelse "";

    var fuzzer = Fuzzer.init(allocator, port, valid_pass);
    defer fuzzer.deinit();

    fuzzer.fuzz(1000) catch |err| switch (err) {
        else => |e| {
            eprintln("ircfuzz : encountered fatal error {!}\n", .{e});
            return (1);
        },
    };

    return (0);
}
