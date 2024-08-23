// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   smlx.zig                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/14 10:45:53 by pollivie          #+#    #+#             //
//   Updated: 2024/08/14 10:45:53 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const glfw = @import("mach-glfw");
const opt = @import("builtin");

const AllocatorError = std.mem.Allocator.Error;
const Allocator = std.mem.Allocator;
const Image = glfw.Image;
const Window = glfw.Window;
const Monitor = glfw.Monitor;
const InitHints = glfw.InitHints;

pub const SmlxImage = struct {
    image_handle: Image,
    height: usize,
    width: usize,
    stride: usize,
    allocator: Allocator,

    pub fn init(allocator: Allocator, width: usize, height: usize) AllocatorError!SmlxImage {
        return SmlxImage{
            .image_handle = try glfw.Image.init(allocator, @truncate(width), @truncate(height), width * height * @bitSizeOf(i32)),
            .height = height,
            .width = width,
            .stride = @bitSizeOf(i32),
            .allocator = allocator,
        };
    }

    pub fn drawPixel(image: *SmlxImage, pos_x: usize, pos_y: usize, color: u32) void {
        if (pos_x > image.width or pos_y > image.height) return;
        const a: u32 = (color >> 0) & 0xFF;
        const r: u32 = (color >> 8) & 0xFF;
        const g: u32 = (color >> 16) & 0xFF;
        const b: u32 = (color >> 24) & 0xFF;
        image.image_handle.pixels[pos_y * image.width + pos_x + 0] = @truncate(a);
        image.image_handle.pixels[pos_y * image.width + pos_x + 1] = @truncate(r);
        image.image_handle.pixels[pos_y * image.width + pos_x + 2] = @truncate(g);
        image.image_handle.pixels[pos_y * image.width + pos_x + 3] = @truncate(b);
    }

    pub fn deinit(image: *SmlxImage) void {
        image.image_handle.deinit(image.allocator);
    }
};

pub const SmlxWindow = struct {
    window_handle: Window,
    height: usize,
    width: usize,

    pub fn init(width: usize, height: usize, title: [*:0]const u8, monitor: ?Monitor) SmlxWindow {
        return SmlxWindow{
            .window_handle = glfw.Window.create(@truncate(width), @truncate(height), title, monitor, null, .{}) orelse unreachable,
            .height = height,
            .width = width,
        };
    }

    pub fn deinit(window: *SmlxWindow) void {
        window.window_handle.destroy();
    }
};

pub const SmlxInstance = struct {
    allocator: Allocator,
    height: usize,
    width: usize,
    window: SmlxWindow,
    image: SmlxImage,

    pub fn init(allocator: Allocator, width: usize, height: usize, title: [*:0]const u8) AllocatorError!SmlxInstance {
        _ = glfw.init(.{});
        return SmlxInstance{
            .allocator = allocator,
            .width = width,
            .height = height,
            .window = SmlxWindow.init(width, height, title, null),
            .image = try SmlxImage.init(allocator, width, height),
        };
    }

    pub fn drawClear(smlx: *SmlxInstance, color: u32) void {
        for (0..smlx.height) |h| {
            for (0..smlx.width) |w| {
                smlx.image.drawPixel(w, h, color);
            }
        }
    }

    pub fn drawBegin(smlx: *SmlxInstance) void {
        glfw.makeContextCurrent(smlx.window.window_handle);
    }

    // pub fn drawEnding(_: *SmlxInstance) void {
    // }

    pub fn shouldClose(smlx: *const SmlxInstance) bool {
        return (smlx.window.window_handle.shouldClose());
    }

    pub fn deinit(smlx: *SmlxInstance) void {
        smlx.image.deinit();
        smlx.window.deinit();
        glfw.terminate();
    }
};
