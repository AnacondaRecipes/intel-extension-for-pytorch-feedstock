#!/bin/bash
set -ex

# This is silly, but Intel needs a specific commit of their oneDNN stuff.
pushd third_party/llga
git init
git remote add origin https://github.com/oneapi-src/oneDNN/
git fetch
git checkout origin/master -ft
git reset --hard 4c69e4051571c06ba1928a083852b46548d1f4a8
# This is even more silly, that their commit of oneDNN needs another specific commit
# of oneDNN itself.
pushd third_party/oneDNN
git init
git remote add origin https://github.com/oneapi-src/oneDNN/
git fetch
git checkout origin/master -ft
git reset --hard 52b5f107dd9cf10910aaa19cb47f3abf9b349815
popd
popd

# Symlink llvm-config-13 to llvm-config.
ln -s $BUILD_PREFIX/bin/llvm-config $BUILD_PREFIX/bin/llvm-config-13
# Symlink some llvm-14 headers to their llvm-13 header locations.
ln -s $BUILD_PREFIX/include/llvm/MC/TargetRegistry.h $BUILD_PREFIX/include/llvm/Support/TargetRegistry.h

# Now build
export DNNL_GRAPH_BUILD_COMPILER_BACKEND=1
python setup.py clean
python setup.py bdist_wheel
python -m pip install --force-reinstall --no-build-isolation --no-deps dist/*.whl
