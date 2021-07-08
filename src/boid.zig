const std = @import("std");
const gfx = @import("gfx.zig");

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn add(self: Self, other: Self) Self {
            return Self{ .x = self.x + other.x, .y = self.y + other.y };
        }

        pub fn mul(self: Self, k: T) Self {
            return Self{ .x = k * self.x, .y = k * self.y };
        }

        pub fn magnitude(self: Self) T {
            return std.math.sqrt(self.x * self.x + self.y * self.y);
        }

        pub fn with_magnitude(self: Self, magnitude_: T) Self {
            return self.mul(magnitude_ / self.magnitude());
        }

        pub fn unit(self: Self) Self {
            return self.with_magnitude(@as(T, 1));
        }
    };
}

pub const Boid = struct {
    pos: Vec2(f64),
    velocity: Vec2(f64),

    pub fn create_random(rand: *std.rand.Random) Boid {
        const pos = Vec2(f64){ .x = rand.float(f64), .y = rand.float(f64) };

        const direction = rand.float(f64) * std.math.tau;
        const speed = rand.float(f64) * 0.01;
        const velocity = Vec2(f64){
            .x = speed * std.math.cos(direction),
            .y = speed * std.math.sin(direction),
        };
        return .{ .pos = pos, .velocity = velocity };
    }

    pub fn update(self: *Boid) void {
        self.pos = self.pos.add(self.velocity);
        if (self.pos.x < 0.0) {
            self.pos.x += 1.0;
        }
        if (self.pos.x >= 1.0) {
            self.pos.x -= 1.0;
        }
        if (self.pos.y < 0.0) {
            self.pos.y += 1.0;
        }
        if (self.pos.y >= 1.0) {
            self.pos.y -= 1.0;
        }
    }

    pub fn render(self: Boid, canvas: gfx.Canvas) void {
        var screen_pos = self.pos.mul(@intToFloat(f64, canvas.width));
        gfx.dot(canvas, @floatToInt(isize, screen_pos.x), @floatToInt(isize, screen_pos.y), 3, gfx.Color{ .r = 0, .g = 0, .b = 0 });

        var tip_screen_pos = self.velocity.with_magnitude(20.0).add(screen_pos);
        gfx.line(
            canvas,
            @floatToInt(isize, screen_pos.x),
            @floatToInt(isize, screen_pos.y),
            @floatToInt(isize, tip_screen_pos.x),
            @floatToInt(isize, tip_screen_pos.y),
            gfx.Color{ .r = 0, .g = 0, .b = 0 },
        );
    }
};
