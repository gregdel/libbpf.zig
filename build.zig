const std = @import("std");

pub fn build(b: *std.Build) void {
    const upstream = b.dependency("libbpf", .{});
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libelf = b.dependency("elfutils", .{
        .target = target,
        .optimize = optimize,
    }).artifact("elf");

    const zlib = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    }).artifact("z");

    const lib = b.addLibrary(.{
        .name = "bpf",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .sanitize_c = .off,
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
        .flags = &.{
            "-D_LARGEFILE64_SOURCE",
            "-D_FILE_OFFSET_BITS=64",
        },
    });
    lib.root_module.linkLibrary(libelf);
    lib.root_module.linkLibrary(zlib);
    lib.root_module.addIncludePath(upstream.path("include"));
    lib.root_module.addIncludePath(upstream.path("include/uapi"));
    lib.root_module.addIncludePath(upstream.path("src"));

    lib.installHeadersDirectory(upstream.path("src"), "bpf", .{
        .include_extensions = &.{
            "bpf.h",
            "bpf_core_read.h",
            "bpf_endian.h",
            "bpf_helper_defs.h",
            "bpf_helpers.h",
            "bpf_tracing.h",
            "btf.h",
            "libbpf.h",
            "libbpf_common.h",
            "libbpf_legacy.h",
            "libbpf_version.h",
            "skel_internal.h",
            "usdt.bpf.h",
        },
    });
    b.installArtifact(lib);
}
