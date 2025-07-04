const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});
const Renderer = @import("renderer.zig").Renderer;
const Board = @import("board.zig").Board;

pub fn main() !void {

    // Initialize renderer
    var renderer = try Renderer.init();
    defer renderer.deinit();

    var board = try Board.init(renderer.sdl_r);
    defer board.deinit();

    var event: sdl.SDL_Event = undefined;
    var running = true;
    while (running) {
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => {
                    running = false;
                },

                else => {},
            }
        }
        renderer.clear();
        renderer.drawCheckerBoard();
        renderer.drawPieces(&board);
        renderer.present();
    }
}
