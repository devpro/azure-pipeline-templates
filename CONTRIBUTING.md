# Contributing

## Tools

- No third party container images are to be used, except the `devpro/ubuntu-*` ones.
- A tool that the image does not have is downloaded from its official release at a fixed version, and its SHA256 is checked before use.
- A package comes from a list of hashes, as with `pip install --require-hashes`.
