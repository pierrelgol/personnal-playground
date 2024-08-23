const std = @import("std");
const rl = @import("raylib");
const gui = @import("raygui");
const smlx = @import("smlx.zig");
const SmlxInstance = smlx.SmlxInstance;
const SmlxWindow = smlx.SmlxWindow;
const SmlxImage = smlx.SmlxImage;
const SmlxColor = smlx.SmlxColor;
const WIDTH = 1920;
const HEIGHT = 1080;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.detectLeaks())
            @panic("Leaks Detected");
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();
    var buffer = try allocator.alloc(i32, HEIGHT * WIDTH);
    defer allocator.free(buffer);

    var smlx_instance = SmlxInstance.init(allocator, HEIGHT, WIDTH, "DoomNukem3D");
    defer smlx_instance.deinit();
    const image = rl.Image{
        .data = buffer.ptr,
        .width = WIDTH,
        .height = HEIGHT,
        .mipmaps = 1,
        .format = .pixelformat_uncompressed_r8g8b8a8,
    };

    const texture = rl.loadTextureFromImage(image);
    var len: usize = 100;
    var pos_x: usize = @divExact(WIDTH + len, 2);
    var pos_y: usize = @divExact(HEIGHT + len, 2);

    rl.setTargetFPS(0);
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressedRepeat(.key_equal))
            len -|= 20 * (1.0 / rl.getFrameTime());
        if (rl.isKeyPressedRepeat(.key_minus))
            len +|= 20 * (1.0 / rl.getFrameTime());
        if (rl.isKeyPressedRepeat(.key_w)) {
            pos_y -|= 20 * (1.0 / rl.getFrameTime());
        } else if (rl.isKeyPressedRepeat(.key_s)) {
            pos_y +|= 20 * (1.0 / rl.getFrameTime());
        }
        if (rl.isKeyPressedRepeat(.key_a)) {
            pos_x -|= 20 * (1.0 / rl.getFrameTime());
        } else if (rl.isKeyPressedRepeat(.key_d)) {
            pos_x +|= 20 * (1.0 / rl.getFrameTime());
        }

        for (0..HEIGHT) |h| {
            for (0..WIDTH) |w| {
                buffer[h * WIDTH + w] = rl.Color.black.toInt();
            }
        }

        for (pos_y..pos_y +| len) |h| {
            for (pos_x..pos_x +| len) |w| {
                if (h < HEIGHT and w < WIDTH)
                    buffer[h * WIDTH + w] = rl.Color.yellow.toInt();
            }
        }
        rl.updateTexture(texture, image.data);

        rl.drawFPS(25, 25);
        rl.updateTexture(texture, image.data);
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
        rl.drawTexture(texture, 0, 0, rl.Color.white);
        rl.endDrawing();
    }
}
