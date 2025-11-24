load(":providers.bzl", "ImageManifestInfo")

def _consumer_impl(ctx):
    image_info = ctx.attr.image[ImageManifestInfo]
    base_image = image_info.base_image
    description = ctx.actions.declare_file(ctx.label.name + "_description.txt")
    base_symlink = ctx.actions.declare_file(ctx.label.name + "_base_image.bin")
    ctx.actions.write(
        output = description,
        content = "Base image: {}\nLayers:\n{}".format(
            base_image.short_path,
            "\n".join([layer.short_path for layer in image_info.layers.to_list()]),
        ),
    )
    ctx.actions.symlink(
        target_file = base_image,
        output = base_symlink,
    )
    return [DefaultInfo(files = depset([
        description,
        base_symlink,
    ]))]

consumer = rule(
    implementation = _consumer_impl,
    attrs = {
        "image": attr.label(providers = [ImageManifestInfo], mandatory = True),
    },
)
