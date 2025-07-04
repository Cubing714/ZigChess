const std = @import("std");
const Board = @import("board.zig").Board;
const ROW_SIZE = @import("board.zig").ROW_SIZE;
const COL_SIZE = @import("board.zig").COL_SIZE;

pub const Game = struct {
    board: Board,
};
