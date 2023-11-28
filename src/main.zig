const std = @import("std");
const testing = std.testing;


pub fn Stack(comptime T: type) type {

    const StackNode = struct {
        const Self = @This();

        value: T,
        next: ?*Self,
    };

    return struct {
        const Self = @This();
        top: ?*StackNode,
        alloc: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator) Self {
            return .{
                .alloc = alloc,
                .top = null,
            };
        }

        fn deinit(self: Self) void {
            var head = self.top;
            while (head) |node| {
                head = node.next;
                self.alloc.destroy(node);
            }
        }

        fn print(self: *const Self) void {
            std.log.info("Stack:", .{});
            var head = self.top;
            var idx: u32 = 0;
            while (head) |node| {
                std.log.info("{d} ~> {d}", .{ idx, node.value });
                idx = idx + 1;
                head = node.next;
            }
        }

        fn isEmpty(self: *Self) bool {
            if(self.top) |_| {
                return false;
            } else {
                return true;
            }
        }

        fn push(self: *Self, value: T) !void {
            var node = try self.alloc.create(StackNode);
            errdefer self.alloc.destroy(node);

            node.value = value;
            var top = self.top;
            node.next = top;

            self.top = node;
        }

        fn pop(self: *Self) !void {
            if(self.top) |top| {
                self.top = top.next;
                self.alloc.destroy(top);
            } else {
                return error.StackEmpty;
            }
        }

        fn peek(self: *Self) ?T {
            if (self.top) |node| {
                return node.value;
            }
            return null;
        }
    };
}



pub fn main() !void {
    // var
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gp.allocator();
    var stack = Stack(i64).init(alloc);
    try stack.push(5);
    try stack.push(7);
    try stack.push(9);
    stack.print();
    while (!stack.isEmpty()) {
        try stack.pop();
        stack.print();
    }

}

test "push and peek works" {
    var stack = Stack(i64).init(std.testing.allocator);
    defer stack.deinit();

    try stack.push(5);
    
    if (stack.peek()) |val| {
        try testing.expect(val == 5);
    } else {
        return error.StackEmptyAfterPush;
    }
}

test "pop errors on empty" {
    var stack = Stack(void).init(std.testing.allocator);
    defer stack.deinit();
    try testing.expectError(error.StackEmpty, stack.pop());
}
