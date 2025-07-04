const std = @import("std");
const sdl = @import("renderer.zig").sdl;
const rect = @import("renderer.zig").rect;
const Piece = @import("piece.zig").Piece;
const PieceType = @import("piece.zig").PieceType;
const Color = @import("piece.zig").Color;

pub const ROW_SIZE = 8;
pub const COL_SIZE = 8;

const startBoardState: [ROW_SIZE][COL_SIZE]u8 = .{
    .{ 'r', 'n', 'b', 'q', 'k', 'b', 'n', 'r' },
    .{ 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p' },
    .{ '.', '.', '.', '.', '.', '.', '.', '.' },
    .{ '.', '.', '.', '.', '.', '.', '.', '.' },
    .{ '.', '.', '.', '.', '.', '.', '.', '.' },
    .{ '.', '.', '.', '.', '.', '.', '.', '.' },
    .{ 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p' },
    .{ 'r', 'n', 'b', 'q', 'k', 'b', 'n', 'r' },
};

pub const Board = struct {
    board: [ROW_SIZE][COL_SIZE]Piece,

    pub fn init(sdl_r: ?*sdl.SDL_Renderer) !Board {
        var board: [ROW_SIZE][COL_SIZE]Piece = undefined;
        for (0..ROW_SIZE) |row| {
            for (0..COL_SIZE) |col| {
                var c: Color = undefined;
                if (row >= 4) {
                    c = Color.WHITE;
                } else {
                    c = Color.BLACK;
                }

                var p: PieceType = undefined;
                switch (startBoardState[row][col]) {
                    'r' => {
                        p = PieceType.ROOK;
                    },
                    'n' => {
                        p = PieceType.KNIGHT;
                    },
                    'b' => {
                        p = PieceType.BISHOP;
                    },
                    'q' => {
                        p = PieceType.QUEEN;
                    },
                    'k' => {
                        p = PieceType.KING;
                    },
                    'p' => {
                        p = PieceType.PAWN;
                    },
                    else => {
                        p = PieceType.EMPTY;
                    },
                }

                var p_rect = rect;
                p_rect.x += @as(c_int, @intCast(col)) * p_rect.w;
                p_rect.y += @as(c_int, @intCast(row)) * p_rect.h;

                board[row][col] = try Piece.init(c, p, p_rect);

                if (p != PieceType.EMPTY) try board[row][col].loadTexture(sdl_r);
                std.debug.print("Piece created: {}\n", .{board[row][col]});
            }
        }

        return Board{
            .board = board,
        };
    }

    pub fn deinit(self: *Board) void {
        for (&self.board) |*row| {
            for (row) |*piece| {
                piece.deinit();
            }
        }
    }
};
