load(":providers.bzl", "ImageManifestInfo")

def _consumer_impl(ctx):
    # The custom transition wraps the dependency in a list even though only one
    # configured target is produced, so unwrap it before accessing providers.
    image_target = ctx.attr.image[0]
    image_info = image_target[ImageManifestInfo]
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


# Transition that forces //:materialize_blobs = True
def _materialize_blobs_transition_impl(settings, attr):
    return {
        "//:materialize_blobs": True,
    }

_materialize_blobs_transition = transition(
    implementation = _materialize_blobs_transition_impl,
    inputs = [],  # we don't read any settings
    outputs = ["//:materialize_blobs"],
)

consumer = rule(
    implementation = _consumer_impl,
    attrs = {
        "image": attr.label(
            providers = [ImageManifestInfo],
            mandatory = True,
            cfg = _materialize_blobs_transition,
        ),
    },
)
