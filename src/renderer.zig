const std = @import("std");
pub const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL_image.h");
});

const Piece = @import("piece.zig").Piece;
const Color = @import("piece.zig").Color;
const PieceType = @import("piece.zig").PieceType;
const Board = @import("board.zig").Board;
const ROW_SIZE = @import("board.zig").ROW_SIZE;
const COL_SIZE = @import("board.zig").COL_SIZE;

const WINDOW_WIDTH = 1600;
const WINDOW_HEIGHT = 900;

pub const rect = sdl.SDL_Rect{
    .x = (WINDOW_WIDTH - 800) / 2, // X pos in pixels
    .y = (WINDOW_HEIGHT - 800) / 2, // Y pos in pixels
    .w = 100, // Width
    .h = 100, // Height
};

pub const Renderer = struct {
    sdl_r: ?*sdl.SDL_Renderer, // SDL Renderer
    window: ?*sdl.SDL_Window,

    pub fn init() !Renderer {
        const stderr = std.io.getStdErr().writer();

        // Try to init SDL2
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
            try stderr.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
            std.process.exit(1);
        }

        if ((sdl.IMG_Init(sdl.IMG_INIT_PNG) & sdl.IMG_INIT_PNG) == 0) {
            try stderr.print("SDL_IMG_Init Error: {s}\n", .{sdl.SDL_GetError()});
            std.process.exit(1);
        }

        const driver = sdl.SDL_GetCurrentVideoDriver();
        try stderr.print("SDL Video Driver: {s}\n", .{driver});

        const window = sdl.SDL_CreateWindow(
            "CHESS GAME",
            sdl.SDL_WINDOWPOS_CENTERED,
            sdl.SDL_WINDOWPOS_CENTERED,
            WINDOW_WIDTH,
            WINDOW_HEIGHT,
            sdl.SDL_WINDOW_SHOWN,
        );

        if (window == null) {
            try stderr.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
            std.process.exit(1);
        }

        const sdl_r = sdl.SDL_CreateRenderer(window, -1, 0);
        if (sdl_r == null) {
            try stderr.print("SDL_CreateRenderer Error: {s}", .{sdl.SDL_GetError()});
        }

        std.debug.print("SDL was successfully initialized!\n", .{});

        return Renderer{
            .sdl_r = sdl_r,
            .window = window,
        };
    }

    pub fn deinit(self: *Renderer) void {
        sdl.SDL_DestroyRenderer(self.sdl_r);
        sdl.SDL_DestroyWindow(self.window);
        sdl.SDL_Quit();
    }

    pub fn clear(self: *Renderer) void {
        _ = sdl.SDL_SetRenderDrawColor(self.sdl_r, 100, 100, 100, 255);
        _ = sdl.SDL_RenderClear(self.sdl_r);
    }

    pub fn present(self: *Renderer) void {
        _ = sdl.SDL_RenderPresent(self.sdl_r);
    }

    pub fn drawCheckerBoard(self: *Renderer) void {
        for (0..ROW_SIZE) |row| {
            for (0..COL_SIZE) |col| {
                const sum = row + col;

                var square = rect;

                // Change position
                square.x += @as(c_int, @intCast(col)) * square.w;
                square.y += @as(c_int, @intCast(row)) * square.h;

                // Check if sum is even or odd
                if ((sum % 2) == 0) {
                    // White  square
                    _ = sdl.SDL_SetRenderDrawColor(self.sdl_r, 219, 153, 105, 255);
                    _ = sdl.SDL_RenderFillRect(self.sdl_r, &square);
                } else {
                    // Black square
                    _ = sdl.SDL_SetRenderDrawColor(self.sdl_r, 79, 44, 20, 255);
                    _ = sdl.SDL_RenderFillRect(self.sdl_r, &square);
                }

                // std.debug.print("Created square:\n\t{}\n", .{square});
            }
        }
    }

    pub fn drawPieces(self: *Renderer, board: *Board) void {
        for (0..ROW_SIZE) |row| {
            for (0..COL_SIZE) |col| {
                var piece = board.board[row][col];
                // If piece is not empty then draw it
                if (piece.ptype != PieceType.EMPTY) {
                    _ = sdl.SDL_RenderCopy(self.sdl_r, piece.texture, null, &piece.sdl_rect);
                }
            }
        }
    }
};
