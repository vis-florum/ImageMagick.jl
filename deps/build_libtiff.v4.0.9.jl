using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libtiff"], :libtiff),
    LibraryProduct(prefix, String["libtiffxx"], :libtiffxx),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/SimonDanisch/LibTIFFBuilder/releases/download/v1.0.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libtiff.v4.0.9.aarch64-linux-gnu.tar.gz", "d4b5fc2aa7e62d07414a19ad980ab734b2eb5fecf9226d14322a2aaca31dd4ab"),
    Linux(:aarch64, :musl) => ("$bin_prefix/libtiff.v4.0.9.aarch64-linux-musl.tar.gz", "33db60c463f4acab9d6fe519a8ed5fc3366b126a6661106c338e491e03e51933"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/libtiff.v4.0.9.arm-linux-gnueabihf.tar.gz", "98f91418ffb2556d78eeaca965618d7218cb52e3ac07450f1e2b7e8969d9fee5"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/libtiff.v4.0.9.arm-linux-musleabihf.tar.gz", "6a8df8fd463a1360ab4f58b6c69d26504f68ae136dd3b807d9fa25f2206ec1a2"),
    Linux(:i686, :glibc) => ("$bin_prefix/libtiff.v4.0.9.i686-linux-gnu.tar.gz", "56f02ceaab858b74cddf14593e73b677e8cbf1cb78d5611fe7f28a8f772d27fb"),
    Linux(:i686, :musl) => ("$bin_prefix/libtiff.v4.0.9.i686-linux-musl.tar.gz", "6e09eaa9d2e97465f07f01e1bb9f22b935ac89245dd5360b7206a8d39092417b"),
    Windows(:i686) => ("$bin_prefix/libtiff.v4.0.9.i686-w64-mingw32.tar.gz", "6bdbd2f9ab41e59cadacbd01309f345aa59bd9afdfcf935c8746ad58c35694e3"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libtiff.v4.0.9.powerpc64le-linux-gnu.tar.gz", "32854bc4c7286eb2b76a255a9a24e9dffa46b2a1056ff77f2e4f1759a71a2f52"),
    MacOS(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-apple-darwin14.tar.gz", "669c2164823590be90d3211d52a5934cec5cdd7923e73e853d7e42e3aa749e98"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/libtiff.v4.0.9.x86_64-linux-gnu.tar.gz", "bc75574e1fbecd401e74f5d13c75eb101210ec7a7d1fef7e5ecc0ced33a5c532"),
    Linux(:x86_64, :musl) => ("$bin_prefix/libtiff.v4.0.9.x86_64-linux-musl.tar.gz", "8a70ae547730d5c3d0f230c47a02ca80241c491735043419c8a89ba516763d92"),
    FreeBSD(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-unknown-freebsd11.1.tar.gz", "aae1fc9eeebe7b0b6fdbaf4fe4f8d7e717e1ec6bcd72b87e4a65177cee3dee04"),
    Windows(:x86_64) => ("$bin_prefix/libtiff.v4.0.9.x86_64-w64-mingw32.tar.gz", "bfe319539672e344933041b9134289b6036961ea665016d0e080db0087cd641b"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_tiff.jl"), products)
