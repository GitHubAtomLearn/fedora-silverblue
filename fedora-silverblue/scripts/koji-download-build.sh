#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

function main() {

    # Compile Python files to bytecode after installation.
    # https://docs.astral.sh/uv/reference/cli/#uv-sync--compile-bytecode
    export UV_COMPILE_BYTECODE=1

    # The method to use when installing packages from the global cache.
    # https://docs.astral.sh/uv/reference/cli/#uv-sync--link-mode
    export UV_LINK_MODE=copy

    # Configure the Python directory so it is consistent.
    # The directory to store the Python installation in.
    # https://docs.astral.sh/uv/reference/cli/#uv-python-install--install-dir
    # export UV_PYTHON_INSTALL_DIR=/opt/python

    # Whether uv should prefer system or managed Python versions.
    # Only use the managed Python version.
    # https://docs.astral.sh/uv/reference/environment/#uv_python_preference
    # export UV_PYTHON_PREFERENCE=only-managed

    # Require use of uv-managed Python versions.
    # https://docs.astral.sh/uv/reference/cli/#uv-python-install--managed-python
    export UV_MANAGED_PYTHON=1

    # Disable the development dependency group
    # https://docs.astral.sh/uv/reference/cli/#uv-sync--no-dev
    export UV_NO_DEV=1

    # Assert that the uv.lock will remain unchanged.
    # https://docs.astral.sh/uv/reference/cli/#uv-sync--locked
    export UV_LOCKED=1

    # Warning: `/root/.local/bin` is not on your PATH.
    # To use installed Python executables, run `export PATH="/root/.local/bin:$PATH"`
    # or `uv python update-shell`.
    # export PATH="/root/.local/bin:$PATH"
    export PATH="/root/.local/bin:/tmp/uv:$PATH"

    # pwd
    # ls -Zlathri
    if [[ ! -d "/var/roothome" ]]; then
        mkdir /var/roothome
    fi
    # ls -Zlathri /root
    # ls -Zlathri /var/roothome

    # Install Python before the project for caching
    # /tmp/uv/uv python install 3.14
    # /tmp/uv/uv python list --verbose --only-installed --all-versions
    # uv python install --verbose 3.14
    uv python install 3.14
    uv python list --verbose --only-installed --all-versions
    # ls -Zlathri
    # ls -Zlathri /var/roothome
    # ls -Zlathri /tmp
    # ls -Zlathri /tmp/scripts
    # ls -Zlathri /.venv

    # dnf install --assumeyes --refresh --allowerasing python3-devel krb5-workstation krb5-server krb5-devel gcc
    # dnf install --assumeyes --refresh --allowerasing python3-devel krb5-devel gcc
    # rpm --query --all | grep krb5
    # cat /etc/krb5.conf
    # krb5-config --help
# EORUN

# RUN --mount=type=cache,target=/root/.cache/uv \
# RUN <<EORUN
# RUN --mount=type=cache,target=/root/.cache/uv \
#     --mount=type=bind,source=scripts/uv.lock,target=uv.lock,readonly,relabel=shared \
#     --mount=type=bind,source=scripts/pyproject.toml,target=pyproject.toml,readonly,relabel=shared <<EORUN
    # --mount=type=bind,source=uv.lock,target=uv.lock \
    # --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    # set -xeuo pipefail
    # pwd
    # ls -Zlathri
    # ls -Zlathri /tmp
    # ls -Zlathri /tmp/scripts
    # pwd && ls -Zlathri &&\
    # uv sync --locked --no-dev
    # uv sync --locked --no-install-project --no-dev
    # /tmp/uv/uv sync --directory /tmp/scripts --no-install-local --no-install-project --no-install-workspace
    # uv sync --verbose --directory /tmp/scripts --no-install-local --no-install-project --no-install-workspace
    uv sync --directory /tmp/scripts --no-install-local --no-install-project --no-install-workspace
    # pwd
    # ls -Zlathri
    # ls -Zlathri /
    # ls -Zlathri ..
    mkdir /tmp/rpms
    # /tmp/uv/uv run \
    uv run \
        --verbose \
        --directory /tmp/scripts /tmp/scripts/koji-download-build.py \
        --frozen --locked --managed-python --no-dev --no-python-downloads --no-sync --offline
    # uv run --frozen --locked --managed-python --no-dev --no-python-downloads --no-sync --offline \
    #     --directory /tmp/scripts /tmp/scripts/koji-download-build.py
    # /tmp/scripts/.venv/bin/python /tmp/scripts/koji-download-build.py
    ls -Zlathri /tmp/rpms
    dnf install --assumeyes --refresh --allowerasing /tmp/rpms/*.rpm
    # dnf remove --assumeyes --refresh python3-devel krb5-devel gcc
    # dnf remove --assumeyes --refresh --no-autoremove python3-devel krb5-devel gcc
    
}
main "${@}"
