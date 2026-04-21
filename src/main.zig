const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdargs_iter = init.minimal.args.iterate();

    const io = init.io;
    // Skip program name
    _ = stdargs_iter.next();

    const inputFilePath = stdargs_iter.next() orelse "-";
    const outputFilePath = stdargs_iter.next() orelse "-";

    var input_file = blk: {
        if (std.mem.eql(u8, inputFilePath, "-")) {
            break :blk std.Io.File.stdin();
        } else {
            break :blk std.Io.Dir.cwd().openFile(io, inputFilePath, .{ .mode = .read_only }) catch |e| {
                std.log.err("Failed to open input file {s}: {}", .{ inputFilePath, e });
                return e;
            };
        }
    };
    defer input_file.close(io);
    var reader_buf: [16 * 1024]u8 = undefined;
    var input_reader = input_file.reader(io, &reader_buf);
    var input = &input_reader.interface;

    const output_file = blk: {
        if (std.fs.path.dirname(outputFilePath)) |parent| {
            std.Io.Dir.cwd().createDirPath(io, parent) catch |e| {
                std.log.err("Failed to create path {s}: {}", .{ parent, e });
                return e;
            };
        }
        if (std.mem.eql(u8, outputFilePath, "-")) {
            break :blk std.Io.File.stdout();
        } else {
            break :blk std.Io.Dir.cwd().createFile(io, outputFilePath, .{}) catch |e| {
                std.log.err("Failed to open output file {s}: {}", .{ outputFilePath, e });
                return e;
            };
        }
    };
    defer output_file.close(io);

    var output_buffer: [16 * 1024]u8 = undefined;
    var output_writer = output_file.writer(io, &output_buffer);
    const output = &output_writer.interface;

    var isCode = false;
    while (true) {
        const line = input.takeDelimiter('\n') catch |e| {
            switch (e) {
                else => return e,
            }
        } orelse break;
        const trimmedLine = std.mem.trimStart(u8, line, &[_]u8{ ' ', '\t' });
        if (std.mem.startsWith(u8, trimmedLine, "```")) {
            isCode = !isCode;
            continue;
        }
        if (isCode) {
            _ = try output.write(line);
            _ = try output.writeByte('\n');
        }
    }
    try output.flush();
}
