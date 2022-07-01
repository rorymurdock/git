# Git

[![macOS 11 build Git](https://github.com/rorymurdock/git/actions/workflows/auto_build.yml/badge.svg)](https://github.com/rorymurdock/git/actions/workflows/auto_build.yml)

This build repo was created to incorporate improvements by [@dscho](https://github.com/dscho) to [Tim Harper's repo](https://github.com/timcharper/git_osx_installer/issues). The aim is to automate the building of Git for macOS into a pipeline and help provide the Mac community with updated binary releases for autopkg.

## Building

Once a day GitHub actions compare the tags from the [Git repo](https://github.com/git/git/tags) against what has been built here. If there is a missing tag then it will in turn trigger the [Auto build](.github/workflows/auto_build.yml) action to build a release

## Using in autopkg

You can use autopkg to download and import Git into Munki using [these recipies](https://github.com/rorymurdock/rorymurdock-recipes/tree/main/Git)
