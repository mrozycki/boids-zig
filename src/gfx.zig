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

pub fn line(canvas: Canvas, x1: isize, y1: isize, x2: isize, y2: isize, color: Color) void {
    const gradient = @intToFloat(f64, y1 - y2) / @intToFloat(f64, x1 - x2);
    if (std.math.absFloat(gradient) <= 1.0) {
        var x = std.math.min(x1, x2);
        var y = @intToFloat(f64, if (x1 < x2) y1 else y2);
        const end_x = std.math.max(x1, x2);
        while (x <= end_x) : ({
            x += 1;
            y += gradient;
        }) {
            canvas.set_pixel(x, @floatToInt(isize, y), color);
        }
    } else {
        const x_gradient = 1.0 / gradient;
        var y = std.math.min(y1, y2);
        var x = @intToFloat(f64, if (y1 < y2) x1 else x2);
        const end_y = std.math.max(y1, y2);
        while (y <= end_y) : ({
            y += 1;
            x += x_gradient;
        }) {
            canvas.set_pixel(@floatToInt(isize, x), y, color);
        }
    }
}

pub fn dot(canvas: Canvas, cx: isize, cy: isize, radius: isize, color: Color) void {
    var y = cy - radius;
    while (y < cy + radius) : (y += 1) {
        var x = cx - radius;
        while (x < cx + radius) : (x += 1) {
            if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius) {
                canvas.set_pixel(x, y, color);
            }
        }
    }
}
