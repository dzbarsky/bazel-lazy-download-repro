load("@downloader//:downloader.bzl", "DOWNLOADER")

def _download_impl(rctx):
    downloader_path = rctx.path(DOWNLOADER)
    rctx.watch(downloader_path)
    args = [
        str(downloader_path),
        rctx.attr.url,
        rctx.attr.downloaded_file_path,
    ]
    if rctx.attr.sleep > 0:
        args.extend(["--sleep", str(rctx.attr.sleep)])
    exec_result = rctx.execute(
        args,
    )
    if exec_result.return_code != 0:
        fail("download failed {}: {}{}".format(args, exec_result.stderr, exec_result.stdout))
    rctx.file(
        "BUILD.bazel",
        """exports_files(["{}"])""".format(rctx.attr.downloaded_file_path),
    )

download = repository_rule(
    implementation = _download_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "downloaded_file_path": attr.string(mandatory = True),
        "sleep": attr.int(default = 0),
    },
)
