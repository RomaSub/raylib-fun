const std = @import("std");
const rl = @import("raylib");

const Ball = struct {
    color1: rl.Color,
    color2: rl.Color,
    x: i32,
    y: i32,
    velocity_y: f32,
    radius: i32,
    is_active: bool,
};

const Gravity = 500.0;
const BounceDamping = 0.7;

pub fn main() anyerror!void {
    const screenWidth = 1200;
    const screenHeight = 800;

    rl.initWindow(screenWidth, screenHeight, "raylib zig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    var rand = prng.random();

    var balls = std.ArrayList(Ball).init(std.heap.page_allocator);
    defer balls.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            const ball = Ball{
                .color1 = try getRandomColor(&rand),
                .color2 = try getRandomColor(&rand),
                .x = rl.getMouseX(),
                .y = rl.getMouseY(),
                .velocity_y = 0.0,
                .radius = 20,
                .is_active = true,
            };

            try balls.append(ball);
        }

        for (balls.items) |*ball| {
            if (!ball.is_active) continue;

            ball.y += @intFromFloat(ball.velocity_y * rl.getFrameTime());
            ball.velocity_y += Gravity * rl.getFrameTime();

            if (ball.y + ball.radius >= screenHeight) {
                ball.y = screenHeight - ball.radius;
                ball.velocity_y = -ball.velocity_y * BounceDamping;

                if (@abs(ball.velocity_y) < 50.0) {
                    ball.velocity_y = 0;
                }
            }

            rl.drawCircleGradient(ball.x, ball.y, @floatFromInt(ball.radius), ball.color1, ball.color2);
        }
    }
}

fn getRandomColor(rand: *std.rand.Random) !rl.Color {
    const r = rand.intRangeAtMost(u8, 0, 255);
    const g = rand.intRangeAtMost(u8, 0, 255);
    const b = rand.intRangeAtMost(u8, 0, 255);
    // const a = rand.intRangeAtMost(u8, 0, 255);
    const a = 255;
    return rl.Color.init(r, g, b, a);
}
