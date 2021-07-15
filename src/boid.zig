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

        pub fn sub(self: Self, other: Self) Self {
            return Self{ .x = self.x - other.x, .y = self.y - other.y };
        }

        pub fn mul(self: Self, k: T) Self {
            return Self{ .x = k * self.x, .y = k * self.y };
        }

        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y;
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

fn random_velocity(rand: *std.rand.Random) Vec2(f64) {
    const direction = rand.float(f64) * std.math.tau;
    const speed = rand.float(f64) * 0.01;
    return .{
        .x = speed * std.math.cos(direction),
        .y = speed * std.math.sin(direction),
    };
}

pub const Boid = struct {
    pos: Vec2(f64),
    velocity: Vec2(f64),

    pub fn create_random(rand: *std.rand.Random) Boid {
        const pos = Vec2(f64){ .x = rand.float(f64), .y = rand.float(f64) };
        return .{ .pos = pos, .velocity = random_velocity(rand) };
    }

    fn distance_to(self: *const Boid, other: *const Boid) f64 {
        return self.pos.sub(other.pos).magnitude();
    }

    fn can_see(self: *const Boid, other: *const Boid) bool {
        const visibility_distance_limit: f64 = 0.12;
        const visibility_angle_limit: f64 = std.math.pi / 3.0;

        if (self == other) {
            return false;
        }

        if (other.pos.sub(self.pos).magnitude() > visibility_distance_limit) {
            return false;
        }

        return self.velocity.unit().dot(other.pos.sub(self.pos).unit()) > std.math.cos(visibility_angle_limit);
    }

    pub fn update(self: *Boid, others: []Boid, rand: *std.rand.Random) void {
        const average_velocity_weight: f64 = 0.1;
        const random_noise_velocity_weight: f64 = 0.1;
        const middle_position_weight: f64 = 0.05;
        const minimum_distance_weight: f64 = 0.15;
        const max_velocity: f64 = 0.01;
        const min_distance: f64 = 0.05;

        // average velocity adjustment
        var neighbors: f64 = 0.0;
        var total_neighbor_velocity: Vec2(f64) = .{ .x = 0.0, .y = 0.0 };
        for (others) |other| {
            if (self.can_see(&other)) {
                neighbors += 1.0;
                total_neighbor_velocity = total_neighbor_velocity.add(other.velocity);
            }
        }

        if (neighbors > 0.0) {
            var average_neighbor_velocity = total_neighbor_velocity.mul(1.0 / neighbors);
            self.velocity = self.velocity.add(average_neighbor_velocity.sub(self.velocity).mul(average_velocity_weight));
        }

        // middle position adjustment
        var average_neighbor_distance: f64 = 0.0;
        for (others) |other| {
            if (self.can_see(&other)) {
                average_neighbor_distance += self.distance_to(&other) / neighbors;
            }
        }

        for (others) |other| {
            if (self.can_see(&other)) {
                const dist = self.distance_to(&other);
                const s2o = other.pos.sub(self.pos);
                self.velocity = self.velocity.add(s2o.mul((dist - average_neighbor_distance) / dist * middle_position_weight / (neighbors + 1.0)));

                // minimum distance adjustment
                if (dist < min_distance) {
                    self.velocity = self.velocity.add(s2o.mul(1.0 - min_distance / dist).mul(minimum_distance_weight / (neighbors + 1.0)));
                }
            }
        }

        // random noise adjustment
        const random_noise_velocity = random_velocity(rand);
        self.velocity = self.velocity.add(random_noise_velocity.mul(random_noise_velocity_weight));

        // maximum velocity adjustment
        if (self.velocity.magnitude() > max_velocity) {
            self.velocity = self.velocity.with_magnitude(max_velocity);
        }

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
