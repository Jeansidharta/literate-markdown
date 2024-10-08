const std = @import("std");

pub fn main() !void {
    // const gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    const stdinReader = std.io.getStdIn().reader();
    const stdoutWriter = std.io.getStdOut().writer();

    var isCode = false;
    var buffer: [16512]u8 = undefined;
    while (true) {
        const line = (try stdinReader.readUntilDelimiterOrEof(&buffer, '\n')) orelse break;
        const trimmedLine = line[std.mem.indexOfNone(u8, line, &[_]u8{ ' ', '\t' }) orelse 0 ..];
        if (std.mem.startsWith(u8, trimmedLine, "```")) {
            isCode = !isCode;
            continue;
        }
        if (isCode) {
            _ = try stdoutWriter.write(line);
            _ = try stdoutWriter.write("\n");
        }
    }
}
