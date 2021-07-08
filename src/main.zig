const std = @import("std");
const gfx = @import("gfx.zig");
const Boid = @import("boid.zig").Boid;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var rand = std.rand.DefaultPrng.init(0);

    const allocator = &arena.allocator;

    var boids = try allocator.alloc(Boid, 100);
    for (boids) |*boid| {
        boid.* = Boid.create_random(&rand.random);
    }

    var canvas = try gfx.Canvas.new(800, 800, allocator);

    var filename: ["render/frame_0000.ppm".len]u8 = undefined;
    var frame: usize = 0;
    while (frame < 100) : (frame += 1) {
        var filename_writer = std.io.fixedBufferStream(&filename).writer();
        try filename_writer.print("render/frame_{d:0>4}.ppm", .{frame});
        std.log.info("Rendering frame #{} to {s}", .{ frame, filename });

        var file = try std.fs.cwd().createFile(std.mem.span(&filename), .{});
        var writer = std.io.bufferedWriter(file.writer()).writer();

        canvas.clear(gfx.Color{ .r = 255, .g = 255, .b = 255 });
        for (boids) |boid| {
            boid.render(canvas);
        }

        try canvas.print(@TypeOf(writer), &writer);

        for (boids) |*boid| {
            boid.update();
        }
    }
}
