load("@downloader//:downloader.bzl", "DOWNLOADER")

def _trampolines_impl(rctx):
    rctx.file("dummy", "")

    target = rctx.attr.targets[0]

    rctx.file("defs.bzl", """
    
def _compute_data_bin(materialize):
    return Label("%s") if materialize else Label("//:dummy")

def _data_bin_impl(ctx):
    return [
        DefaultInfo(files = depset([ctx.file._file])),
    ]

_data_bin = rule(
    implementation = _data_bin_impl,
    attrs = {
        "_file": attr.label(default = _compute_data_bin, allow_single_file = True),
        "materialize": attr.bool(default = False),
    },
)

def data_bin(name, visibility):
    _data_bin(
        name = name,
        visibility = visibility,
        materialize = select({
            "@@//:materialize_blobs_enabled": True,
            "//conditions:default": False,
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
