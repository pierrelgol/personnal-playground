// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   puzzle.zig                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/26 18:10:10 by pollivie          #+#    #+#             //
//   Updated: 2024/08/26 18:10:11 by pollivie         ###   ########.fr       //
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
const Trie = @import("trie.zig").Trie;
const TrieNode = @import("trie.zig").TrieNode;

pub const Puzzle = packed struct {
    var len: usize = 0;
    state: []u8,

    pub inline fn init(state: []u8, dimension: usize) Puzzle {
        len = dimension;
        return .{
            .state = state,
        };
    }

    pub inline fn indexOf(puzzle: *const Puzzle, value: u8) isize {
        return @intCast(std.mem.indexOfScalar(u8, puzzle.state, value) orelse unreachable);
    }

    pub inline fn swapAt(puzzle: *Puzzle, at: u8, with: u8) void {
        const temp: u8 = puzzle.state[at];
        puzzle.state[at] = puzzle.state[with];
        puzzle.state[with] = temp;
    }

    pub fn manhattanDistance(puzzle: *const Puzzle, dimension: u8, target: *const Puzzle) isize {
        var total_distance: isize = 0;

        for (puzzle.state, 0..) |tile, index| {
            if (tile == 0) continue;
            const current_x: isize = index / dimension;
            const current_y: isize = index % dimension;

            const target_index: isize = target.indexOf(tile);
            const target_x: isize = target_index / dimension;
            const target_y: isize = target_index % dimension;

            const distance = @abs(current_x - target_x) + @abs(current_y - target_y);
            total_distance += distance;
        }
    }

    pub fn memoize(puzzle: *const Puzzle, root: *Trie) !void {
        try root.insert(puzzle.state);
    }
};
