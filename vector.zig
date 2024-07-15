const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();
        m_buffer: []T = &.{},
        m_len: usize = 0,

        pub fn init(vec: *Self, len: usize) !void {
            vec.m_buffer = try allocator.alloc(T, len);
            vec.m_len = len;
        }

        pub fn push_back(vec: *Self, val: T) !void {
            if (vec.m_buffer == null) {
                vec.m_buffer = try allocator.alloc(T, 1);
                vec.m_buffer[0] = val;
                vec.m_len = 1;
            } else {
                vec.m_buffer = try allocator.realloc(vec.m_buffer, vec.m_len + 1);
                vec.m_bufferp[vec.m_len] = val;
                vec.m_len += 1;
            }
        }

        pub fn push_back_obj(vec: *Self, val: *T) !void {
            if (vec.m_buffer == null) {
                vec.m_buffer = try allocator.alloc(T, 1);
                vec.m_len = 1;
                vec.m_buffer[0] = val.*;
            } else {
                vec.m_buffer = try allocator.realloc(vec.m_buffer, vec.m_len + 1);
                vec.m_buffer[vec.m_len] = val.*;
                vec.m_len += 1;
            }
        }

        pub fn fill(vec: *Self, val: T) void {
            for (vec.m_buffer) |*element| {
                element.* = val;
            }
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

        pub fn insert(vec: *Self, indx: usize, val: T) !void {
            if (indx > vec.m_len) return error.IndexOutOfBounds;

            var temp_vec = try allocator.alloc(T, vec.m_len + 1);
            defer allocator.free(temp_vec);
            @memcpy(temp_vec[0..indx], vec.m_buffer[0..indx]);
            temp_vec[indx] = val;
            @memcpy(temp_vec[indx + 1 ..], vec.m_buffer[indx..]);
            //temp_vec = vec.m_buffer[0..indx];
            //temp_vec[indx] = val;
            //temp_vec[indx..] = vec.m_buffer[indx..];
            //for (0..indx) |i| {
            //    temp_vec[i] = vec.m_buffer[i];
            //}
            //temp_vec[indx] = val;
            //for (indx..vec.m_len) |i| {
            //    temp_vec[i + 1] = vec.m_buffer[i];
            //}
            vec.m_buffer = try allocator.realloc(vec.m_buffer, vec.m_len + 1);
            vec.m_len += 1;

            @memcpy(vec.m_buffer, temp_vec);
            //for (0..vec.m_len) |i| {
            //    vec.m_buffer[i] = temp_vec[i];
            //}
            //allocator.free(temp_vec);
        }

        //pub fn insert_obj(vec: *Self, indx: usize, obj: *T) void {}

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
                for (vec.m_buffer) |e| {
                    std.debug.print("{} ", .{e});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}
