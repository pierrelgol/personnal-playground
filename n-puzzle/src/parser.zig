// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   parser.zig                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/26 17:59:32 by pollivie          #+#    #+#             //
//   Updated: 2024/08/26 17:59:33 by pollivie         ###   ########.fr       //
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

pub const Parser = struct {
    dimension: usize,
    current: []u8,
    target: []u8,

    pub const MAX_PUZZLE_DIMENSION = 16;

    pub const ParserError = error{
        MissingComment,
        MissingDimension,
        MissingContent,
        MissmatchDescription,
        IncorrectConfiguration,
    };

    pub fn init(allocator: Allocator, raw_content: []u8) (AllocatorError || fmt.ParseIntError || ParserError)!Parser {
        var line_iter = mem.tokenizeScalar(u8, raw_content, '\n');
        const comment_line = line_iter.next() orelse return ParserError.MissingComment;
        _ = comment_line;
        const dimension_line = line_iter.next() orelse return ParserError.MissingDimension;

        const dimension = fmt.parseInt(usize, dimension_line, 10) catch 0;
        if (dimension == 0 or dimension > MAX_PUZZLE_DIMENSION) {
            return ParserError.IncorrectConfiguration;
        }

        const total_tiles = dimension * dimension;
        const tiles: []u8 = try allocator.alloc(u8, total_tiles);
        errdefer allocator.free(tiles);

        const snail_tiles: []u8 = try allocator.alloc(u8, total_tiles);
        errdefer allocator.free(snail_tiles);

        var tile_count: usize = 0;
        var tile_iter = mem.tokenizeAny(u8, line_iter.rest(), " \n");
        while (tile_iter.next()) |tile| : (tile_count += 1) {
            tiles[tile_count] = try fmt.parseInt(u8, tile, 10);
            snail_tiles[tile_count] = 0;
        }

        if (tile_count != total_tiles) {
            return ParserError.IncorrectConfiguration;
        }

        return Parser{
            .dimension = dimension,
            .current = try allocator.dupe(u8, tiles),
            .target = try allocator.dupe(u8, makeTarget(snail_tiles, dimension)),
        };
    }

    pub fn makeTarget(buffer: []u8, dimension: usize) []u8 {
        const total_tiles = dimension * dimension;
        var x: usize = 0;
        var y: usize = 0;
        var left_bound: usize = 0;
        var right_bound: usize = dimension - 1;
        var top_bound: usize = 0;
        var bottom_bound: usize = dimension - 1;

        var index: usize = 0;
        while (index < (total_tiles)) {
            y = left_bound;
            while (y <= right_bound) : (y += 1) {
                buffer[top_bound * dimension + y] = @truncate(index + 1);
                index += 1;
            }
            top_bound += 1;

            x = top_bound;
            while (x <= bottom_bound) : (x += 1) {
                buffer[x * dimension + right_bound] = @truncate(index + 1);
                index += 1;
            }
            right_bound -= 1;

            if (top_bound <= bottom_bound) {
                y = right_bound;
                while (y >= left_bound) : (y -= 1) {
                    buffer[bottom_bound * dimension + y] = @truncate(index + 1);
                    index += 1;
                    if (y == 0) break;
                }
                bottom_bound -= 1;
            }

            if (left_bound <= right_bound) {
                x = bottom_bound;
                while (x >= top_bound) : (x -= 1) {
                    buffer[x * dimension + left_bound] = @truncate(index + 1);
                    index += 1;
                    if (x == 0) break;
                }
                left_bound += 1;
            }
        }
        const replace_by_zero_index = std.mem.indexOfMax(u8, buffer);
        buffer[replace_by_zero_index] = 0;
        return (buffer);
    }

    pub fn deinit(puzzle: *Parser, allocator: Allocator) void {
        allocator.free(puzzle.current);
        allocator.free(puzzle.target);
    }

    pub fn display(puzzle: Parser) !void {
        const stdout_writer = std.io.getStdOut().writer();

        for (puzzle.current, 1..) |tile, i| {
            if (i % puzzle.dimension == 0) {
                try stdout_writer.print("{d:0>3}\n", .{tile});
            } else {
                try stdout_writer.print("{d:0>3},", .{tile});
            }
        }

        try stdout_writer.print("\n", .{});
        for (puzzle.target, 1..) |tile, i| {
            if (i % puzzle.dimension == 0) {
                try stdout_writer.print("{d:0>3}\n", .{tile});
            } else {
                try stdout_writer.print("{d:0>3},", .{tile});
            }
        }
    }
};

const table = @import("inputs.zig").input_table;

test "random number" {
    const allocator = std.testing.allocator;
    const inputs = std.testing.fuzzInput(.{ .corpus = table });
    const buffer: []u8 = try allocator.dupe(u8, inputs);
    defer allocator.free(buffer);
    const config = Parser.init(allocator, buffer) catch Parser{
        .dimension = 0,
        .current = undefined,
        .target = undefined,
    };
    _ = config;
}
