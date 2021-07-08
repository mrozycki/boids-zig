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
    try canvas.print(@TypeOf(stdout), &stdout);
}
