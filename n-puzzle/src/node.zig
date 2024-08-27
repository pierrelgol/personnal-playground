// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   node.zig                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/26 23:11:00 by pollivie          #+#    #+#             //
//   Updated: 2024/08/26 23:11:01 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const heap = std.heap;
const process = std.process;
const AllocatorError = mem.Allocator.Error;
const Allocator = mem.Allocator;
const SegmentedList = std.SegmentedList;
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

pub fn ZobristHash(comptime N: usize) type {
    return struct {
        const Self = @This();
        table: [N][N]u8,

        pub fn init(random: *std.Random.DefaultPrng) Self {
            var table: [N][N]u8 = undefined;
            for (0..N) |col| {
                for (0..N) |row| {
                    table[col][row] = @truncate(random.next() % N);
                }
            }
            return .{
                .table = table,
            };
        }

        pub fn hash(zobrist_hash: *const Self, key: []u8) u64 {
            var result: u64 = 0;
            for (0..N) |i| {
                result ^= zobrist_hash.table[i][key[i]];
            }
            return (result);
        }
    };
}

pub fn AstarNodePool(comptime T: type, capacity: usize) type {
    return struct {
        const Self = @This();
        free_node: SegmentedList(AstarNode, capacity),
        used_node: SegmentedList(AstarNode, 0),
        allocator: Allocator,

        pub fn init(allocator: Allocator) !Self {
            return .{
                .free_node = SegmentedList(AstarNode, capacity),
                .used_node = SegmentedList(AstarNode, 0),
                .allocator = allocator,
            };
        }

        pub const AstarNode = struct {
            /// The item or state represented by this node, e.g., position or configuration
            item: T = undefined,

            /// Cost from the start node to this node
            g_score: f32 = 0,

            /// Heuristic estimate of the cost from this node to the goal
            h_score: f32 = 0,

            /// Total cost (g_score + h_score)
            f_score: f32 = 0,

            /// Optional parent node or reference (for path reconstruction)
            parent: ?u32 = null,

            /// Method to init a node
            pub fn init(item: T) @This() {
                return .{
                    .item = item,
                    .g_score = 0,
                    .h_score = 0,
                    .f_score = 0,
                    .parent = null,
                };
            }

            /// Method to compare two nodes based on their f_score
            pub fn compareFn(a: *const @This(), b: *const @This()) Order {
                if (a.f_score < b.f_score) {
                    return .lt;
                } else if (a.f_score > b.f_score) {
                    return .gt;
                } else {
                    return .eql;
                }
            }

            /// Method to calculate the f_score from g_score and h_score
            pub fn updateFScore(self: *@This()) void {
                self.f_score = self.g_score + self.h_score;
            }

            /// Method to debug print
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
    };
}
