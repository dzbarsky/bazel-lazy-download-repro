load("@downloader//:downloader.bzl", "DOWNLOADER")

def _download_lazy_impl(ctx):
    arguments = [
            ctx.attr.url,
            ctx.outputs.downloaded_file_path.path,
    ]
    if ctx.attr.sleep > 0:
        arguments.extend(["--sleep", str(ctx.attr.sleep)])
    ctx.actions.run(
        outputs = [ctx.outputs.downloaded_file_path],
        executable = ctx.file._tool,
        arguments = arguments,
        mnemonic = "DownloadLazy",
    )

download_lazy = rule(
    implementation = _download_lazy_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "downloaded_file_path": attr.output(mandatory = True),
        "sleep": attr.int(default = 0),
        "_tool": attr.label(
            default = DOWNLOADER,
            allow_single_file = True,
        ),
    },
)
