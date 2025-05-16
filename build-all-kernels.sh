#!/bin/bash
set -e

KERNEL_SRC_DIR="./linux"
BRANCHES=("qcom-msm8974-6.11.y")
ARCH="arm"
CROSS_COMPILE="arm-linux-gnueabihf-"
PKG_VERSION="1.0-1"
CONFIG_LOCALVERSION="-citronics-lemon"

ROOT_DIR=$(pwd)

cd "$KERNEL_SRC_DIR"
git fetch --all
cd - > /dev/null

CONFIGS_DIR="$ROOT_DIR/configs"
OUTPUT_BASE="$ROOT_DIR/output"
BUILD_BASE="$ROOT_DIR/build"

for BRANCH in "${BRANCHES[@]}"; do
    VERSION="${BRANCH#qcom-msm8974-}"
    KERNEL_NAME="msm8974-${VERSION}"
    CONFIG_FILE="${CONFIGS_DIR}/${KERNEL_NAME}.config"
    OUTPUT_DIR="${OUTPUT_BASE}/${VERSION}"
    BUILD_DIR="${BUILD_BASE}/${VERSION}"

    echo "🔁 Building branch: $BRANCH"
    echo "⚙️  Using config: $CONFIG_FILE"

    # Remove worktree from Git if it exists
    cd "$KERNEL_SRC_DIR"
    if git worktree list | grep -q "$BUILD_DIR"; then
        git worktree remove --force "$BUILD_DIR"
    fi

    # Ensure folder is gone
    rm -rf "$BUILD_DIR"
    git worktree prune

    # Add clean worktree
    git fetch origin "$BRANCH"
    git worktree add "$BUILD_DIR" "origin/$BRANCH"

    cd "$BUILD_DIR"

    # Setup build environment
    export ARCH="$ARCH"
    export CROSS_COMPILE="$CROSS_COMPILE"

    # Apply config
    cp "$CONFIG_FILE" .config
    make olddefconfig

    # Build the deb packages
    echo "🚧 Building kernel .deb packages for $KERNEL_NAME"
    make -j$(nproc) \
         LOCALVERSION=-citronics-lemon \
         KDEB_PKGVERSION="$PKG_VERSION" \
         deb-pkg

    # Move output
    mkdir -p "$OUTPUT_DIR"
    cd "$BUILD_DIR/.."  # Go to the parent of build dir where .debs are created
    mv ./*.deb "$OUTPUT_DIR"

    echo "✅ Done: $OUTPUT_DIR"
    cd - > /dev/null
done

echo "🎉 All builds completed successfully."