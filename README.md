# Bazel Lazy repository download reproducer

This exists to showcase a common problem in Bazel.
It's hard to defer downloading external data until it is needed.

Here is how to show the problem:

```
bazel clean --expunge
ls $(bazel info output_base)/external/+_repo_rules+example_100mib/data.bin
```

You see that data.bin doesn't exist yet.

```
bazel build //:example_image
ls $(bazel info output_base)/external/+_repo_rules+example_100mib/data.bin
```

You see that `data.bin` was created since we forced Bazel to analyze the `@example_100mib` repo.
We want to avoid that!
Instead, we only want Bazel to fetch the `@example_100mib` repo when we build the consumer:


```
bazel build //:example_consumer
ls $(bazel info output_base)/external/+_repo_rules+example_100mib/data.bin
```

Now there is a good reason for the `data.bin` file to exist, since the file is being accessed by a build rule.


## Explanation

Bazel needs to analyze the expensive repo for the `image` rule, forcing the repo rule to run.

## (Possible) workarounds

- Dormant deps (need to understand how they work, also this is still experimental)
- Late-bound dep (suggested by @dzbarsky, need to look into this)
- Trampoline repo with aliases (suggested by @dzbarsky) -- as far as I understand the suggestion, I don't think that it can work
