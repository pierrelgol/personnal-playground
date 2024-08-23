const std = @import("std");
const smlx = @import("smlx.zig");
const glfw = @import("mach-glfw");

const AllocatorError = std.mem.Allocator.Error;
const Allocator = std.mem.Allocator;

const width = 800;
const height = 600;

pub fn main() !void {
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var instance = try smlx.SmlxInstance.init(allocator, width, height, "DoomNukenGLFW3D");
    defer instance.deinit();

    var image = instance.image;
    var window = instance.window;
    window.window_handle.setOpacity(1.0);
    glfw.makeContextCurrent(instance.window.window_handle);
    while (!instance.shouldClose()) {
        for (0..100) |y| {
            for (0..100) |x| {
                image.drawPixel(x, y, 0xFFFFFF);
            }
        }
        window.window_handle.swapBuffers();
        // instance.drawClear(0x00000000);
        glfw.pollEvents();
    }
}
