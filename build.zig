const std = @import("std");

pub fn build(b: *std.Build) void {
    const upstream = b.dependency("libbpf", .{});
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const elfutils = b.dependency("elfutils", .{
        .target = target,
        .optimize = optimize,
    });
    const libelf = elfutils.artifact("elf");

    const lib = b.addLibrary(.{
        .name = "bpf",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &.{
            "libbpf_probes.c",
            "elf.c",
            "btf_relocate.c",
            "btf.c",
            "ringbuf.c",
            "features.c",
            "netlink.c",
            "libbpf_errno.c",
            "str_error.c",
            "libbpf.c",
            "bpf.c",
            "btf_iter.c",
            "gen_loader.c",
            "strset.c",
            "nlattr.c",
            "hashmap.c",
            "relo_core.c",
            "usdt.c",
            "bpf_prog_linfo.c",
            "btf_dump.c",
            "linker.c",
            "zip.c",
        },
    });
    lib.root_module.linkLibrary(libelf);
    lib.root_module.addIncludePath(upstream.path("include"));
    lib.root_module.addIncludePath(upstream.path("include/uapi"));

    b.installArtifact(lib);
}
