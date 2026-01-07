Name:           PACKAGE_NAME
# renovate: datasource=github-releases depName=OWNER/REPO
Version:        1.0.0
Release:        1%{?dist}
Summary:        Brief description of the package

License:        LICENSE_HERE
URL:            https://github.com/OWNER/REPO
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz

# Build dependencies (uncomment as needed)
# BuildRequires:  gcc
# BuildRequires:  make
# BuildRequires:  rust
# BuildRequires:  cargo
# BuildRequires:  golang
# BuildRequires:  python3-devel
# BuildRequires:  cmake
# BuildRequires:  meson

# Runtime dependencies (uncomment as needed)
# Requires:       some-library

%description
Longer description of the package.
What it does and why it's useful.

%prep
%autosetup

%build
# For Rust projects:
# cargo build --release --locked

# For Go projects:
# go build -v -o %{name}

# For Make projects:
# %make_build

# For Meson projects:
# %meson
# %meson_build

# For CMake projects:
# %cmake
# %cmake_build

%install
# For binary installation:
# install -Dpm0755 -t %{buildroot}%{_bindir}/ target/release/%{name}

# For autotools/make:
# %make_install

# For Meson:
# %meson_install

# For CMake:
# %cmake_install

%files
# Common file entries:
%license LICENSE
%doc README.md
%{_bindir}/%{name}

# For library packages:
# %{_libdir}/lib%{name}.so.*
# %{_includedir}/%{name}/

# For data files:
# %{_datadir}/%{name}/

%changelog
%autochangelog
