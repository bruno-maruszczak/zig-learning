const std = @import("std");
const testing = std.testing;
const print = std.debug.print;

pub fn BinarySearchTree(comptime T: type, comptime lessThan: *const fn (left: T, right: T) bool) type {
    const TreeNode = struct {
        const Self = @This();

        value: T,
        parent: ?*Self,
        left: ?*Self,
        right: ?*Self,
        fn init(self: *Self, value: T) void {
            self.value = value;
            self.parent = null;
            self.left = null;
            self.right = null;
        }
    };

    return struct {
        const Self = @This();

        alloc: std.mem.Allocator,
        root: ?*TreeNode,

        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .alloc = alloc,
                .root = null,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.root == null) {
                return;
            }

            var bottom_left = self.root.?;
            while (bottom_left.left) |l| { // Find the leftmost leaf
                bottom_left = l;
            }

            while (self.root) |head| {
                if (head.right) |right_subtree| {
                    bottom_left.left = right_subtree;
                    while (bottom_left.left) |l| {
                        bottom_left = l;
                    }
                }
                self.root = head.left;
                self.alloc.destroy(head);
            }
        }

        pub fn insert(self: *Self, newValue: T) !void {
            var newNode = try self.alloc.create(TreeNode);
            errdefer self.alloc.destroy(newNode);
            newNode.init(newValue);
            var insertPointParent: ?*TreeNode = null;
            var insertPoint = self.root;

            while (insertPoint) |p| {
                insertPointParent = p;
                if (lessThan(newValue, p.value)) {
                    insertPoint = p.left;
                } else {
                    insertPoint = p.right;
                }
            }
            newNode.parent = insertPointParent;

            if (insertPointParent) |parent| {
                if (lessThan(newValue, parent.value)) {
                    parent.left = newNode;
                } else {
                    parent.right = newNode;
                }
            } else {
                self.root = newNode;
            }
        }

        fn printBranch(node: ?*TreeNode, depth: u32) void {
            if (node) |n| {
                for (0..depth) |_| {
                    print(" ", .{});
                }
                print("~> {d}\n", .{n.value});

                if (n.left) |nl| {
                    print("l:", .{});
                    printBranch(nl, depth + 1);
                }
                if (n.right) |nr| {
                    print("r:", .{});
                    printBranch(nr, depth + 1);
                }
            }
            return;
        }

        pub fn printTree(self: Self) void {
            print("\nTree:\n", .{});
            printBranch(self.root, 0);
            print("\n", .{});
        }
    };
}

fn lt_i64(left: i64, right: i64) bool {
    return left < right;
}

test "empty init and deinit" {
    var tree = BinarySearchTree(i64, lt_i64).init(std.testing.allocator);
    try tree.insert(3);
    try tree.insert(5);
    tree.printTree();
    tree.deinit();
}

test "small tree" {
    var tree = BinarySearchTree(i64, lt_i64).init(std.testing.allocator);
    try tree.insert(5);
    try tree.insert(3);
    try tree.insert(7);
    tree.printTree();
    tree.deinit();
}

test "big tree" {
    var tree = BinarySearchTree(i64, lt_i64).init(std.testing.allocator);
    try tree.insert(30);
    try tree.insert(23);
    try tree.insert(34);
    try tree.insert(15);
    try tree.insert(26);
    try tree.insert(33);
    try tree.insert(44);
    try tree.insert(27);
    try tree.insert(43);
    try tree.insert(50);
    tree.printTree();
    tree.deinit();
}
