load("@downloader//:downloader.bzl", "DOWNLOADER")

def _trampolines_impl(rctx):
    rctx.file("dummy", "")

    target = rctx.attr.targets[0]

    rctx.file("defs.bzl", """
    
def _data_bin_impl(ctx):
    return [
        DefaultInfo(files = depset([ctx.file.file])),
    ]

_data_bin = rule(
    implementation = _data_bin_impl,
    attrs = {
        "file": attr.label(allow_single_file = True),
    },
)

def data_bin(name, visibility):
    _data_bin(
        name = name,
        visibility = visibility,
        file = select({
            "@@//:materialize_blobs_enabled": "%s",
            "//conditions:default": "//:dummy",
        }),
    )
""" % (target))

    rctx.file("BUILD.bazel", """
load("//:defs.bzl", "data_bin") 

exports_files(["dummy"])

data_bin(
    name = "example_100mib_data.bin",
    visibility = ["//visibility:public"],
) 
    """)

trampolines = repository_rule(
    implementation = _trampolines_impl,
    attrs = {
        "targets": attr.label_list(mandatory = True),
    },
)
