const std = @import("std");

pub fn main() !void {
    var stdargs = std.process.args();
    // Skip program name
    _ = stdargs.next();

    const inputFilePath = stdargs.next() orelse "-";
    const outputFilePath = stdargs.next() orelse "-";

    const inputFile = blk: {
        if (std.mem.eql(u8, inputFilePath, "-")) {
            break :blk std.io.getStdIn();
        } else {
            break :blk try std.fs.cwd().openFile(inputFilePath, .{ .mode = .read_only });
        }
    };
    defer inputFile.close();

    const outputFile = blk: {
        if (std.mem.eql(u8, outputFilePath, "-")) {
            break :blk std.io.getStdOut();
        } else {
            break :blk try std.fs.cwd().createFile(outputFilePath, .{});
        }
    };
    defer outputFile.close();

    const fileReader = inputFile.reader();
    const fileWriter = outputFile.writer();

    var isCode = false;
    var buffer: [16512]u8 = undefined;
    while (try fileReader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const trimmedLine = line[std.mem.indexOfNone(u8, line, &[_]u8{ ' ', '\t' }) orelse 0 ..];
        if (std.mem.startsWith(u8, trimmedLine, "```")) {
            isCode = !isCode;
            continue;
        }
        if (isCode) {
            _ = try fileWriter.write(line);
            _ = try fileWriter.write("\n");
        }
    }
}
