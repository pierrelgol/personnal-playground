// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   smlx.zig                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/08/13 19:54:05 by pollivie          #+#    #+#             //
//   Updated: 2024/08/13 19:54:06 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const rl = @import("raylib");
const gui = @import("raygui");
const AllocatorError = std.mem.Allocator.Error;
const Allocator = std.mem.Allocator;

pub const SmlxColor = struct {
    pub const smlx_white = rl.Color.white;
    pub const smlx_black = rl.Color.black;
    pub const smlx_yellow = rl.Color.yellow;
    pub const smlx_red = rl.Color.red;
    pub const smlx_blue = rl.Color.blue;
    pub const smlx_green = rl.Color.green;

    color: rl.Color,

    pub fn init(r: u8, g: u8, b: u8, a: u8) SmlxColor {
        return SmlxColor{
            .color = rl.Color.init(r, g, b, a),
        };
    }

    pub fn toInt(color: SmlxColor) i32 {
        return color.color.toInt();
    }
};

pub const SmlxImage = struct {
    image: rl.Image,
    height: i32,
    width: i32,
    title: ?[*:0]const u8,
    path: ?[*:0]const u8,
    data: *anyopaque,

    pub fn init(height: i32, width: i32, title: [*:0]const u8) SmlxImage {
        const img = rl.loadImageFromScreen();
        return SmlxImage{
            .image = img,
            .height = height,
            .width = width,
            .title = title,
            .path = null,
            .data = img.data,
        };
    }

    pub fn getDataAddr(self: *SmlxImage, out_width: *i32, out_height: *i32) []i32 {
        out_width.* = self.width;
        out_height.* = self.height;
        const ptr = self.data;
        const ptr_to_i32: [*]i32 = @alignCast(@ptrCast(ptr));
        const slice_of_i32 = ptr_to_i32[0..@intCast(self.*.width * self.*.height)];
        return (slice_of_i32);
    }

    pub fn drawPixel(self: *SmlxImage, pos_x: i32, pos_y: i32, color: anytype) void {
        self.image.drawPixel(pos_x, pos_y, color);
    }

    pub fn deinit(smlx_image: SmlxImage) void {
        _ = smlx_image;
    }
};
pub const SmlxCamera = struct {
    camera: rl.Camera,
    projection: rl.CameraProjection,
    mode: rl.CameraMode,
};

pub const SmlxWindow = struct {
    handle: *anyopaque,
    height: i32,
    width: i32,
    title: [*:0]const u8,

    pub fn init(height: i32, width: i32, title: [*:0]const u8) SmlxWindow {
        rl.initWindow(width, height, title);
        return SmlxWindow{
            .height = height,
            .width = width,
            .title = title,
            .handle = rl.getWindowHandle(),
        };
    }

    pub fn deinit(smlx_window: *SmlxWindow) void {
        _ = smlx_window;
        rl.closeWindow();
    }
};

pub const SmlxInstance = struct {
    allocator: Allocator,
    name: []const u8,
    window: SmlxWindow,
    image: SmlxImage,

    pub fn init(allocator: Allocator, height: i32, width: i32, title: [*:0]const u8) SmlxInstance {
        return SmlxInstance{
            .allocator = allocator,
            .name = std.mem.span(title),
            .window = SmlxWindow.init(height, width, title),
            .image = SmlxImage.init(height, width, title),
        };
    }

    pub fn deinit(smlx_instance: *SmlxInstance) void {
        smlx_instance.window.deinit();
        smlx_instance.image.deinit();
    }
};
