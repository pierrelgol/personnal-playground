// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   trie.zig                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/26 18:21:20 by pollivie          #+#    #+#             //
//   Updated: 2024/08/26 18:21:20 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const CHILDREN_MAX: usize = @sizeOf(u8) + 1;
const IS_END_OF_WORD = CHILDREN_MAX - 1;

pub const TrieNode = struct {
    children: [CHILDREN_MAX]?*TrieNode,

    pub fn create(allocator: Allocator) Allocator.Error!*TrieNode {
        var result = try allocator.create(TrieNode);
        @memset(result.children[0..], null);
        result.children[IS_END_OF_WORD] = false;
        return result;
    }

    pub fn destroy(self: *TrieNode, allocator: Allocator) void {
        for (self.children) |maybe_child| {
            if (maybe_child) |child| {
                child.destroy(allocator);
            }
        }
        allocator.destroy(self);
    }

    pub fn isEmpty(self: *TrieNode) bool {
        for (self.children) |maybe_child| {
            if (maybe_child) return (false);
        }
        return (true);
    }

    pub fn removeChild(maybe_self: ?*TrieNode, allocator: Allocator, key: []const u8) bool {
        const self = maybe_self orelse return false;
        if (key.len == 0) {
            if (self.children[IS_END_OF_WORD] == true) {
                self.children[IS_END_OF_WORD] = false;
                if (self.isEmpty()) {
                    allocator.destroy(self);
                    return (true);
                } else {
                    return (false);
                }
            }
        } else {
            const index = key;
            if (self.removeChild(self.children[index], allocator, key[1..])) {
                self.children[index] = null;
                return (!self.children[IS_END_OF_WORD] and self.isEmpty());
            }
        }
        return (false);
    }

    pub fn findPrefixNode(self: *const TrieNode, key: []const u8) ?*TrieNode {
        var maybe_next: ?*TrieNode = self;
        for (key) |char| {
            const index = char;
            const next = maybe_next orelse return (null);
            maybe_next = next.children[index];
        }
        return (maybe_next orelse null);
    }

    pub fn buildPrefix(allocator: Allocator, prefix: []const u8, new_char: u8) ![]u8 {
        var result = try allocator.alloc(u8, prefix.len + 1);
        @memcpy(result[0..prefix.len], prefix);
        result[prefix.len] = new_char;
        return (result);
    }

    pub fn collectSuggestions(maybe_self: ?*TrieNode, prefix: []const u8, allocator: Allocator, collector: *std.ArrayList([]const u8)) !void {
        const self = maybe_self orelse return;
        if (self.children[IS_END_OF_WORD]) {
            try (collector.append(prefix));
        }
        for (self.children, 0..) |maybe_child, i| {
            const child = maybe_child orelse continue;
            const suggestion = try TrieNode.buildPrefix(allocator, prefix, @truncate('a' + i));
            try child.collectSuggestions(suggestion, allocator, collector);
        }
    }
};

pub const Trie = struct {
    maybe_root: ?*TrieNode,
    allocator: Allocator,

    pub fn create(allocator: Allocator) Allocator.Error!*Trie {
        var self = try allocator.create(Trie);
        self.maybe_root = null;
        self.allocator = allocator;
        return self;
    }

    pub fn destroy(self: *Trie) void {
        if (self.maybe_root) |root| {
            root.destroy(self.allocator);
        }
        self.allocator.destroy(self);
    }

    pub fn insert(self: *Trie, key: []const u8) !void {
        if (self.maybe_root == null) {
            self.maybe_root = try TrieNode.create(self.allocator);
        }

        var node = self.maybe_root orelse unreachable;
        for (key) |char| {
            const index = char;
            if (node.children[index] == null) {
                node.children[index] = try TrieNode.create(self.allocator);
            }
            node = node.children[index] orelse unreachable;
        }
        node.children[IS_END_OF_WORD] = true;
    }

    pub fn search(self: *Trie, key: []const u8) bool {
        var node = self.maybe_root orelse return (false);
        for (key) |char| {
            const index = char;
            if (node.children[index] == null) {
                return (false);
            }
            node = node.children[index] orelse return (false);
        }
        return (node.children[IS_END_OF_WORD]);
    }

    pub fn remove(self: *Trie, key: []const u8) bool {
        return (TrieNode.removeChild(self.maybe_root, self.allocator, key));
    }

    pub fn suggest(self: *Trie, prefix: []const u8, allocator: Allocator) !std.ArrayList([]const u8) {
        var result = std.ArrayList([]const u8).init(allocator);
        const root = self.maybe_root orelse return result;
        const prefix_node = root.findPrefixNode(prefix) orelse return result;
        try prefix_node.collectSuggestions(prefix, allocator, &result);
        return (result);
    }
};
