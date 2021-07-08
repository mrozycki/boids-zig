const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Color = struct { r: u8, g: u8, b: u8 };

pub const Canvas = struct {
    pixels: []Color,
    width: usize,
    height: usize,

    pub fn new(width: usize, height: usize, allocator: *Allocator) !Canvas {
        return Canvas{ .pixels = try allocator.alloc(Color, width * height), .width = width, .height = height };
    }

    pub fn clear(self: Canvas, c: Color) void {
        for (self.pixels) |*pixel| {
            pixel.* = c;
        }
    }

    pub fn set_pixel(self: Canvas, x: isize, y: isize, c: Color) void {
        if (x >= 0 and x < @intCast(isize, self.width) and y >= 0 and y < @intCast(isize, self.height)) {
            self.pixels[@intCast(usize, y) * self.width + @intCast(usize, x)] = c;
        }
    }

    pub fn print(self: Canvas, comptime Writer: type, writer: *Writer) !void {
        try writer.print("P3 {} {} 255\n", .{ self.width, self.height });
        for (self.pixels) |pixel| {
            try writer.print("{} {} {} ", .{ pixel.r, pixel.g, pixel.b });
        }
        _ = try writer.context.flush();
    }
};

pub fn rect(canvas: Canvas, start_x: isize, start_y: isize, width: usize, height: usize, color: Color) void {
    var y = start_y;
    while (y < start_y + @intCast(isize, height)) : (y += 1) {
        var x = start_x;
        while (x < start_x + @intCast(isize, width)) : (x += 1) {
            canvas.set_pixel(x, y, color);
        }
    }
}
