const std = @import("std");
const gfx = @import("gfx.zig");

pub fn main() anyerror!void {
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer()).writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var canvas = try gfx.Canvas.new(800, 800, allocator);
    canvas.clear(gfx.Color{ .r = 255, .g = 255, .b = 255 });
    gfx.rect(canvas, 100, 200, 300, 400, gfx.Color{ .r = 255, .g = 0, .b = 0 });
    var alpha: f64 = 0.0;
    while (alpha < std.math.tau) : (alpha += std.math.tau / 100.0) {
        gfx.line(
            canvas,
            400,
            400,
            400 + @floatToInt(isize, 400.0 * std.math.sin(alpha)),
            400 + @floatToInt(isize, 400.0 * std.math.cos(alpha)),
            gfx.Color{ .r = 0, .g = 0, .b = 0 },
        );
    }
    try canvas.print(@TypeOf(stdout), &stdout);
}
