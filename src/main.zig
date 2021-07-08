const std = @import("std");
const gfx = @import("gfx.zig");
const Boid = @import("boid.zig").Boid;

pub fn main() anyerror!void {
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer()).writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var rand = std.rand.DefaultPrng.init(0);

    const allocator = &arena.allocator;

    var boids = try allocator.alloc(Boid, 100);
    for (boids) |*boid| {
        boid.* = Boid.create_random(&rand.random);
    }

    var canvas = try gfx.Canvas.new(800, 800, allocator);
    canvas.clear(gfx.Color{ .r = 255, .g = 255, .b = 255 });

    for (boids) |boid| {
        boid.render(canvas);
    }

    try canvas.print(@TypeOf(stdout), &stdout);
}
