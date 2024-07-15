const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();
        m_buffer: []T = &.{},
        m_len: usize = 0,
        m_cap: usize = 0,

        pub fn init(vec: *Self, cap: usize) !void {
            vec.m_buffer = try allocator.alloc(T, cap);
            vec.m_cap = cap;
        }

        fn grow(vec: *Self) !void {
            if (vec.m_cap > vec.m_len) return;

            const new_capacity = @max(2 *| vec.m_buffer.len, 1);
            const new_buffer = try allocator.alloc(T, new_capacity);
            @memcpy(new_buffer[0..vec.m_len], vec.m_buffer);
            allocator.free(vec.m_buffer);
            vec.m_buffer = new_buffer;
            vec.m_cap = new_capacity;
        }

        pub fn push_back(vec: *Self, val: T) !void {
            try vec.grow();
            vec.m_buffer[vec.m_len] = val;
            vec.m_len += 1;
        }

        pub fn push_back_obj(vec: *Self, val: *T) !void {
            try vec.grow();
            vec.m_buffer[vec.m_len] = val.*;
            vec.m_len += 1;
        }

        pub fn fill(vec: *Self, val: T) void {
            for (vec.m_buffer) |*element| {
                element.* = val;
            }
            vec.m_len = vec.m_cap;
        }

        pub fn begin(vec: *Self) *T {
            return &vec.m_buffer[0];
        }

        pub fn end(vec: *Self) *T {
            return &vec.m_buffer + vec.m_len;
        }

        pub fn empty(vec: *Self) bool {
            return vec.m_len > 0;
        }

        pub fn size(vec: *Self) usize {
            return vec.m_len;
        }

        pub fn get_cap(vec: *Self) usize {
            return vec.m_cap;
        }

        pub fn insert(vec: *Self, indx: usize, val: T) !void {
            if (indx > vec.m_cap) return error.IndexOutOfBounds;

            try vec.grow();

            var i = vec.m_len;
            while (i > indx) {
                vec.m_buffer[i] = vec.m_buffer[i - 1];
                i -= 1;
            }

            vec.m_buffer[indx] = val;
            vec.m_len += 1;
        }

        pub fn insert_obj(vec: *Self, indx: usize, obj: *T) !void {
            if (indx > vec.m_cap) return error.IndexOutOfBounds;

            try vec.grow();

            var i = vec.m_len;
            while (i > indx) {
                vec.m_buffer[i] = vec.m_buffer[i - 1];
                i -= 1;
            }

            vec.m_buffer[indx] = obj.*;
            vec.m_len += 1;
        }

        pub fn pop(vec: *Self) T {
            if (vec.m_len > 0) {
                const popped_val: T = vec.m_buffer[vec.m_len - 1];
                vec.m_buffer = allocator.realloc(vec.m_buffer, vec.m_len - 1);
                vec.m_len -= 1;
                return popped_val;
            }
        }

        pub fn shrink_to_fit(vec: *Self, len: usize) !void {
            if (size > 0 and size < vec.m_len) {
                vec.m_buffer = try allocator.realloc(vec.m_buffer, len);
            } else {
                std.debug.print("shring_to_fit() size must be less than current buffer length!", .{});
            }
        }

        pub fn resize(vec: *Self, len: usize) !void {
            if (vec.m_buffer == null) {
                try allocator.alloc(T, len);
            } else {
                vec.m_buffer = try allocator.realloc(vec.m_buffer, len);
            }
            vec.m_buffer = len;
        }

        pub fn deinit(vec: *Self) void {
            if (vec.m_len > 0) {
                allocator.free(vec.m_buffer);
                //vec.m_buffer = null;
                vec.m_buffer = &.{};
                vec.m_len = 0;
            }
        }

        // FOR DEBUG PURPOSES
        pub fn print(vec: *Self) void {
            if (T == i32) {
                for (vec.m_buffer[0..vec.m_len]) |e| {
                    std.debug.print("{} ", .{e});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}
