%global debug_package %{nil}

Name:           matugen
# renovate: datasource=github-releases depName=InioX/matugen
Version:        3.1.1
Release:        1%{?dist}
Summary:        Material you color generation tool with templates

License:        GPL-2.0
URL:            https://github.com/InioX/matugen
Source0:       %{url}/archive/refs/tags/v%{version}.tar.gz

BuildRequires: rust
BuildRequires: cargo
BuildRequires: clang

%global _description %{expand:
%{summary}.}

%description %{_description}

%prep
%setup -q
# Tito may create git-based directory names - normalize to current directory
# Find any subdirectory containing Cargo.toml and move contents up
for dir in */; do
    if [ -f "${dir}Cargo.toml" ]; then
        # Move all contents from subdirectory to current directory
        mv "${dir}"* . 2>/dev/null || true
        # Move hidden files (but not . and ..)
        for hidden in "${dir}".*; do
            [ -e "$hidden" ] && [ "$(basename "$hidden")" != "." ] && [ "$(basename "$hidden")" != ".." ] && mv "$hidden" . 2>/dev/null || true
        done
        rmdir "$dir" 2>/dev/null || true
        break
    fi
done

%build
# Explicitly find and cd to directory containing Cargo.toml
# This handles tito's git-based directory naming
SRCDIR=$(find . -name Cargo.toml -type f | head -1 | xargs dirname)
if [ -z "$SRCDIR" ] || [ "$SRCDIR" = "." ]; then
    # Fallback: look for matugen directories
    SRCDIR=$(find . -maxdepth 2 -type d -name "*matugen*" | grep -v "^\.$" | head -1)
fi
if [ -n "$SRCDIR" ] && [ "$SRCDIR" != "." ]; then
    echo "Changing to source directory: $SRCDIR"
    cd "$SRCDIR"
fi
# Verify we're in the right place
if [ ! -f Cargo.toml ]; then
    echo "ERROR: Cargo.toml not found. Current directory: $(pwd)"
    echo "Directory contents:"
    ls -la
    exit 1
fi
CC=clang CXX=clang cargo build --release --locked

%install
install -Dpm0755 -t %{buildroot}%{_bindir}/ target/release/%{name}

%files
%license LICENSE
%{_bindir}/%{name}

%changelog
* Mon Jan 05 2026 John Flynn <johndangerflynn@gmail.com> 3.1.1-1
- new package built with tito

%autochangelog
