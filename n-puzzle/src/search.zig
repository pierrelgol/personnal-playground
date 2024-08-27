// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   search.zig                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/26 18:55:25 by pollivie          #+#    #+#             //
//   Updated: 2024/08/26 18:55:25 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

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
const Puzzle = @import("puzzle.zig").Puzzle;
const Trie = @import("trie.zig").Trie;
const TrieNode = @import("trie.zig").TrieNode;
const Thread = std.Thread;
const ThreadPool = Thread.Pool;
const Order = std.math.Order;
const PriorityQueue = std.PriorityQueue;
const HashSet = std.HashMap;

pub fn Astar(
    comptime T: type,
    comptime context: anytype,
    comptime compare: fn (context: anytype, a: T, b: T) Order,
) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        open_set: PriorityQueue(T, context, compare),
        close_set: HashSet([]u8, T, context, 70),

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .open_set = PriorityQueue(T, context, compare).init(allocator, context),
                .close_set = HashSet([]u8, T, context, 70).init(allocator),
            };
        }

        pub fn deinit(astar: *Self) void {
            astar.open_set.deinit();
            astar.close_set.deinit();
        }
    };
}
