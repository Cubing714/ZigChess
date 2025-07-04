const std = @import("std");
const sdl = @import("renderer.zig").sdl;

pub const Color = enum {
    WHITE,
    BLACK,
};

pub fn colorToStr(color: Color) []const u8 {
    return switch (color) {
        .WHITE => "white",
        .BLACK => "black",
    };
}

pub const PieceType = enum {
    PAWN,
    KNIGHT,
    BISHOP,
    ROOK,
    QUEEN,
    KING,
    EMPTY,
};

pub fn pieceTypeToStr(ptype: PieceType) []const u8 {
    return switch (ptype) {
        .PAWN => "pawn",
        .KNIGHT => "knight",
        .BISHOP => "bishop",
        .ROOK => "rook",
        .QUEEN => "queen",
        .KING => "king",
        .EMPTY => "empty",
    };
}

pub const Piece = struct {
    color: Color,
    ptype: PieceType,
    texture: ?*sdl.SDL_Texture,
    sdl_rect: sdl.SDL_Rect,

    pub fn init(color: Color, ptype: PieceType, rect: sdl.SDL_Rect) !Piece {
        return Piece{
            .color = color,
            .ptype = ptype,
            .texture = null,
            .sdl_rect = rect,
        };
    }

    pub fn deinit(self: *Piece) void {
        sdl.SDL_DestroyTexture(self.texture);
    }

    pub fn loadTexture(self: *Piece, sdl_r: ?*sdl.SDL_Renderer) !void {
        var buffer: [64]u8 = undefined;
        const color_str = colorToStr(self.color);
        const type_str = pieceTypeToStr(self.ptype);
        const path = try std.fmt.bufPrintZ(buffer[0..], "./assets/textures/{s}-{s}.png", .{ color_str, type_str });

        _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "linear");

        self.texture = sdl.IMG_LoadTexture(sdl_r, path.ptr);
        if (self.texture == null) {
            std.debug.print("IMG_LoadTexture Error: {s}", .{sdl.SDL_GetError()});
            std.process.exit(1);
        }
    }
};

const SQUARE_SIZE = @import("renderer.zig").SQUARE_SIZE;
const WINDOW_WIDTH = @import("renderer.zig").WINDOW_WIDTH;
const WINDOW_HEIGHT = @import("renderer.zig").WINDOW_HEIGHT;
const ROW_SIZE = @import("board.zig").ROW_SIZE;
const COL_SIZE = @import("board.zig").COL_SIZE;

pub fn displayCoordsToBoardIdx(x: i32, y: i32) ?struct { row: usize, col: usize } {
    const board_bound_box = sdl.SDL_Rect{
        .x = (WINDOW_WIDTH - (SQUARE_SIZE * COL_SIZE)) / 2,
        .y = (WINDOW_HEIGHT - (SQUARE_SIZE * COL_SIZE)) / 2,
        .w = COL_SIZE * SQUARE_SIZE,
        .h = ROW_SIZE * SQUARE_SIZE,
    };

    const point = sdl.SDL_Point{
        .x = @intCast(x),
        .y = @intCast(y),
    };

    if (sdl.SDL_PointInRect(&point, &board_bound_box) == 0) {
        return null;
    }

    // Calcuate column and row indices for array
    const bbx = board_bound_box.x;
    const bby = board_bound_box.y;

    const col = @divTrunc((x - bbx), SQUARE_SIZE);
    const row = @divTrunc((y - bby), SQUARE_SIZE);

    return .{
        .row = @intCast(row),
        .col = @intCast(col),
    };
}
