const std = @import("std");
const intStack = @import("./stack.zig").Stack(i64);



pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gp.allocator();
    var stack = intStack.init(alloc);
    try stack.push(5);
    try stack.push(7);
    try stack.push(9);
    stack.print();
    while (!stack.isEmpty()) {
        try stack.pop();
        stack.print();
    }

}

