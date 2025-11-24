"""Repository rule that builds downloader using Go binary"""

load("@go_host_compatible_sdk_label//:defs.bzl", "HOST_COMPATIBLE_SDK")

def _bootstrap_impl(rctx):
    go_sdk_label = Label("@" + rctx.attr._go_sdk_name + "//:ROOT")
    go_root = str(rctx.path(go_sdk_label).dirname)
    extension = _executable_extension(rctx)
    go_tool = go_root + "/bin/go" + extension
    go_mod = rctx.path(rctx.attr.go_mod)
    src_root = rctx.path(go_mod).dirname
    downloader_file = src_root.get_child("downloader.go")
    rctx.watch(go_tool)
    rctx.watch(go_mod)
    rctx.watch(downloader_file)
    rctx.symlink(go_mod, "go.mod")
    rctx.symlink(downloader_file, "downloader.go")
    for src in rctx.attr.tool_srcs:
        rctx.watch(src)
    args = [
        go_tool,
        "build",
        "-o",
        rctx.path("./downloader.exe"),
        "-ldflags=-s -w",
        "-trimpath",
        "./downloader.go",
    ]
    exec_result = rctx.execute(
        args,
        environment = {
            "CGO_ENABLED": "0",
        },
    )
    if exec_result.return_code != 0:
        fail("go build failed {}: {}{}".format(args, exec_result.stderr, exec_result.stdout))
    rctx.file(
        "BUILD.bazel",
        """exports_files(["downloader.exe"])""",
    )

    # cleanup symlinks
    rctx.delete("go.mod")
    rctx.delete("downloader.go")

    if hasattr(rctx, "repo_metadata"):
        # allows participating in repo contents cache
        return rctx.repo_metadata(reproducible = True)

    # only to make buildifier happy
    return None

bootstrap = repository_rule(
    implementation = _bootstrap_impl,
    attrs = {
        "tool_srcs": attr.label_list(mandatory = True),
        "go_mod": attr.label(mandatory = True),
        "go_sum": attr.label(mandatory = True),
        "_go_sdk_name": attr.string(default = "@" + HOST_COMPATIBLE_SDK.repo_name),
    },
)

def _executable_extension(rctx):
    extension = ""
    if rctx.os.name.startswith("windows"):
        extension = ".exe"
    return extension
