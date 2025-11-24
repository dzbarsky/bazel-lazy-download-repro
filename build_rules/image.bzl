load(":providers.bzl", "ImageManifestInfo")

def _image_impl(ctx):
    config_file = ctx.actions.declare_file(ctx.label.name + "_config.json")
    # this is just a placeholder for the reproduction and doesn't reflect a real image config
    ctx.actions.write(
        output = config_file,
        content = json.encode({"name": ctx.label.name, "layers": [layer.short_path for layer in ctx.attr.layers]}),
    )
    return [
        DefaultInfo(files = depset([config_file])),
        ImageManifestInfo(
            base_image = ctx.file.base_image,
            layers = depset(ctx.attr.layers),
        )
    ]


image = rule(
    implementation = _image_impl,
    attrs = {
        "base_image": attr.label(allow_single_file = True),
        "layers": attr.label_list(allow_files = True),
    },
    provides = [ImageManifestInfo],
)
