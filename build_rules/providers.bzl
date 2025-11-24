DOC = """\
Information about a single-platform container image.
"""

FIELDS = dict(
    base_image = "Large data blob (File) representing the base image. We want to avoid loading this unless necessary.",
    layers = "Depset of File. This just exists to have a better example. It doesn't matter for this repro.",
)

ImageManifestInfo = provider(
    doc = DOC,
    fields = FIELDS,
)
