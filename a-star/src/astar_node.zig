// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   astar_node.zig                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/29 12:17:57 by pollivie          #+#    #+#             //
//   Updated: 2024/08/29 12:17:57 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const io = std.io;
const formt = std.fmt;
const mem = std.mem;
const math = std.math;
const heap = std.heap;
const debug = std.debug;
const testing = std.testing;

const AllocatorError = mem.Allocator.Error;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;
const Order = math.Order;
const PriorityQueue = std.PriorityQueue;
const SegmentedList = std.SegmentedList;
const ThreadPool = std.Thread.Pool;
const Thread = std.Thread;

pub fn AstarNode(comptime T: type) type {
    return struct {
        const Node = @This();
        item: T,
        h_score: f32,
        g_score: f32,
        f_score: f32,
        parent: ?u32,

        pub fn init(item: T) Node {
            return .{
                .item = item,
                .h_score = 0,
                .g_score = 0,
                .f_score = 0,
                .parent = null,
            };
        }

        pub fn update(self: *Node) void {
            self.f_score = self.h_score + self.g_score;
        }

        pub fn compare(self: *const Node, other: *const Node) Order {
            if (self.f_score < other.f_score)
                return Order.lt
            else if (self.f_score > other.f_score)
                return Order.gt
            else
                return Order.eq;
        }

        pub fn format(
            self: @This(),
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;
            try writer.print("[item : {any}, g_score : {e}, h_score : {e}, f_score : {e}, parent : {?}] ", .{ self.item, self.g_score, self.h_score, self.f_score, self.parent });
        }
    };
}

test "init(item : T) Node" {
    const inputs = testing.fuzzInput(.{});
    if (inputs.len != 0) {
        const node = AstarNode(u8).init(inputs[0]);
        try testing.expectEqual(inputs[0], node.item);
        try testing.expect(node.h_score == 0);
        try testing.expect(node.g_score == 0);
        try testing.expect(node.f_score == 0);
        try testing.expect(node.parent == null);
    }
}

fn fakeScores(start: []const u8, end: []const u8) f32 {
    var score: f32 = 0;

    const len = @min(start.len, end.len);
    if (len == 0) return (score);
    for (start[0..len], end[0..len]) |s, e| {
        score += @floatFromInt((s -| e));
    }
    return (score);
}

test "compare(self: *const Node, other: *const Node) Order" {
    const inputs = testing.fuzzInput(.{});
    const start = inputs;
    const end = inputs;

    var node_a = AstarNode([]const u8).init(start);
    node_a.h_score = fakeScores(node_a.item, end);
    node_a.update();

    var node_b = AstarNode([]const u8).init(start);
    node_b.h_score = fakeScores(node_b.item, end);
    node_b.update();

    try testing.expectApproxEqRel(fakeScores(start, end), node_a.f_score, 0.0001);
    try testing.expect(node_a.compare(&node_b) == Order.eq);
}
