// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   astar.zig                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/29 17:34:44 by pollivie          #+#    #+#             //
//   Updated: 2024/08/29 17:34:44 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const AstarNode = @import("astar_node.zig");
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

pub fn Astar(
    comptime T: type,
    comptime Context: type,
    comptime compareFn: fn (context: Context, a: T, b: T) Order,
    comptime max_load_percentage: u64,
) type {
    return struct {
        const Self = @This();
        const DataType = T;

        tpool: ThreadPool,
        mlock: Thread.Mutex,
        open_set: PriorityQueue(T, Context, compareFn),
        close_set: HashMap(T, void, Context, max_load_percentage),
        allocator: Allocator,

        pub fn init(allocator: Allocator, tpool: ThreadPool) Self {
            return .{
                .allocator = allocator,
                .mlock = Thread.Mutex{},
                .tpool = tpool,
                .open_set = PriorityQueue(T, Context, compareFn),
                .close_set = HashMap(T, void, Context, max_load_percentage),
            };
        }

        pub fn deinit(self: Self) void {
            self.open_set.deinit();
            self.close_set.deinit();
        }
    };
}

test "pub fn init(allocator: Allocator, tpool: ThreadPool) Self" {}
