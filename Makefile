BINS = dwlb
MANS = dwlb.1

PREFIX ?= /usr/local
CFLAGS += -Wall -Wextra -Wno-unused-parameter -Wno-format-truncation -g

COM = components/battery          \
	components/cat                \
	components/cpu                \
	components/datetime           \
	components/disk               \
	components/entropy            \
	components/hostname           \
	components/ip                 \
	components/kernel_release     \
	components/keyboard_indicators\
	components/keymap             \
	components/load_avg           \
	components/netspeeds          \
	components/num_files          \
	components/ram                \
	components/run_command        \
	components/swap               \
	components/temperature        \
	components/uptime             \
	components/user               \
	components/volume             \
	components/wifi

REQ = util

PROT = xdg-shell-protocol               \
	xdg-output-unstable-v1-protocol     \
	wlr-layer-shell-unstable-v1-protocol\
	dwl-ipc-unstable-v2-protocol


all: $(BINS)

config.h:
	cp config.def.h $@

clean:
	$(RM) $(BINS) $(addsuffix .o,$(BINS)) $(addsuffix .o,$(COM)) $(addsuffix .o,$(REQ)) $(addsuffix .o,$(PROT))

install: all
	install -D -t $(PREFIX)/bin $(BINS)
	install -D -m0644 -t $(PREFIX)/share/man/man1 $(MANS)

WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) client-header $(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@
xdg-shell-protocol.c:
	$(WAYLAND_SCANNER) private-code $(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@
xdg-shell-protocol.o: xdg-shell-protocol.h

xdg-output-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) client-header $(WAYLAND_PROTOCOLS)/unstable/xdg-output/xdg-output-unstable-v1.xml $@
xdg-output-unstable-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code $(WAYLAND_PROTOCOLS)/unstable/xdg-output/xdg-output-unstable-v1.xml $@
xdg-output-unstable-v1-protocol.o: xdg-output-unstable-v1-protocol.h

wlr-layer-shell-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) client-header protocols/wlr-layer-shell-unstable-v1.xml $@
wlr-layer-shell-unstable-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code protocols/wlr-layer-shell-unstable-v1.xml $@
wlr-layer-shell-unstable-v1-protocol.o: wlr-layer-shell-unstable-v1-protocol.h

dwl-ipc-unstable-v2-protocol.h:
	$(WAYLAND_SCANNER) client-header protocols/dwl-ipc-unstable-v2.xml $@
dwl-ipc-unstable-v2-protocol.c:
	$(WAYLAND_SCANNER) private-code protocols/dwl-ipc-unstable-v2.xml $@
dwl-ipc-unstable-v2-protocol.o: dwl-ipc-unstable-v2-protocol.h


$(COM:=.o): components.h $(REQ:=.h)

dwlb.o: utf8.h config.h $(PROT:=.h) $(REQ:=.h)

# Protocol dependencies
dwlb: $(PROT:=.o) $(COM:=.o) $(REQ:=.o)

# Library dependencies
dwlb: CFLAGS+=$(shell pkg-config --cflags wayland-client wayland-cursor fcft pixman-1) -s
dwlb: LDLIBS+=$(shell pkg-config --libs wayland-client wayland-cursor fcft pixman-1) -lrt -s

.PHONY: all clean install
