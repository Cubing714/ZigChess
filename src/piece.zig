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

        self.texture = sdl.IMG_LoadTexture(sdl_r, path.ptr);
        if (self.texture == null) {
            std.debug.print("IMG_LoadTexture Error: {s}", .{sdl.SDL_GetError()});
            std.process.exit(1);
        }
    }
};
