// Signed illi

pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");
const Window = @import("Window.zig");

const Coord = struct {
    x: f64,
    y: f64,
};

fn f(n: usize) f64 {
    const x: f64 = @floatFromInt(n);

    const denom = 4.0;

    return std.math.pow(f64, x, 2.0) / denom;
}

fn pol(theta: f64) Coord {
    return .{
        .x = @cos(theta * std.math.pi * 2.0),
        .y = @sin(theta * std.math.pi * 2.0),
    };
}

pub fn main() !void {
    const window = try Window.init("SDL Window", 400, 400, null);
    defer window.deinit();
    const renderer = window.renderer;

    render_loop: while (true) {
        c.SDL_Delay(10);

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    break :render_loop;
                },
                c.SDL_KEYDOWN => {
                    if (event.key.keysym.sym == c.SDLK_ESCAPE) {
                        break :render_loop;
                    }
                },
                else => {},
            }
        }

        var width: c_int = undefined;
        var height: c_int = undefined;
        c.SDL_GetWindowSize(window.window, &width, &height);

        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xff);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0x00, 0xff, 0xff);

        const lower = 0;
        const upper = 10_000;

        const offset = c.SDL_Point{
            .x = @divFloor(width, 2),
            .y = @divFloor(height, 2),
        };

        var acc = Coord{ .x = 0.0, .y = 0.0 };

        const scale = 20.0;

        for (lower..upper + 1) |n| {
            const prev = acc;

            const val = pol(f(n));

            acc.x += val.x;
            acc.y += val.y;

            _ = c.SDL_RenderDrawLine(
                renderer,
                @as(c_int, @intFromFloat(std.math.round(prev.x * scale))) + offset.x,
                -@as(c_int, @intFromFloat(std.math.round(prev.y * scale))) + offset.y,
                @as(c_int, @intFromFloat(std.math.round(acc.x * scale))) + offset.x,
                -@as(c_int, @intFromFloat(std.math.round(acc.y * scale))) + offset.y,
            );
        }

        c.SDL_RenderPresent(renderer);
    }
}
