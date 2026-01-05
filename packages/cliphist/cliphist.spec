Name:          cliphist
# renovate: datasource=github-releases depName=sentriz/cliphist
Version:       0.7.1
Release:       1%{?dist}
Summary:       Clipboard history "manager" for Wayland
Vendor:        sentriz
URL:           https://github.com/%{vendor}/%{name}
Source0:       %{url}/archive/refs/tags/v%{version}.tar.gz
License:       GPL-3.0-or-later

BuildRequires:  golang
BuildRequires:  systemd-rpm-macros
BuildRequires:  git

%description
Clipboard history "manager" for Wayland

%global debug_package %{nil}

%prep
%autosetup

%build
go build -v -o %{name}

%install
install -Dpm 0755  -t %{buildroot}%{_bindir}/ %{name}

%files
%{_bindir}/%{name}

%changelog
* Mon Jan 05 2026 John Flynn <johndangerflynn@gmail.com> 0.7.1-1
- new package built with tito

%autochangelog
