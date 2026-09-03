%global debug_package %{nil}

Name:           noctalia-shell
# renovate: datasource=github-releases depName=noctalia-dev/noctalia-shell
Version:		5.0.1
Release:        1%?dist
Summary:        A Quickshell-based custom shell setup

License:        MIT
URL:            https://github.com/noctalia-dev/noctalia-shell
Source0:        https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz

Requires:	    brightnessctl
Requires:    	dejavu-sans-fonts
Requires:    	gpu-screen-recorder
Requires:	    qt6-qtmultimedia
Requires:       quickshell
Requires:       xdg-desktop-portal

Recommends: 	cava
Recommends:	    cliphist
Recommends:	    ddcutil
Recommends:	    matugen
Recommends:	    power-profiles-daemon
Recommends:	    wlsunset

Packager:       johndanger <admin@johndanger.dev>

%description
A beautiful, minimal desktop shell for Wayland that actually gets out of your way. Built on Quickshell with a warm lavender aesthetic that you can easily customize to match your vibe.

%prep
%autosetup -n noctalia-release

%build

%install
install -d -m 0755 %{buildroot}/etc/xdg/quickshell/noctalia-shell
cp -r ./* %{buildroot}/etc/xdg/quickshell/noctalia-shell/

%files
%doc README.md
%license LICENSE
%{_sysconfdir}/xdg/quickshell/noctalia-shell/

%changelog
* Tues Jan 20 2026 johndanger <admin@johndanger.dev>
- Initial commit
