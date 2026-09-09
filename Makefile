# SimpScore build helpers.
#
# Everything assumes the devcontainer: the Connect IQ SDK, simulator and
# developer key are already on PATH / in ~/.ciq. See .devcontainer/README.md.
# Override any variable on the command line, e.g. `make build DEVICE=fenix7`.

DEVICE      ?= instinct2
KEY         ?= $(HOME)/.ciq/developer_key.der
TYPECHECK   ?= 3
JUNGLE      ?= monkey.jungle
TEST_JUNGLE ?= monkey-test.jungle
APP         ?= SimpScore
BIN         ?= bin

SDK_MANAGER ?= connect-iq-sdk-manager

PRG          := $(BIN)/$(APP).prg
TEST_PRG     := $(BIN)/$(APP)-test.prg
IQ           := $(APP).iq
CONNECTIQ_LOG := /tmp/$(APP)-connectiq.log

.DEFAULT_GOAL := build
.PHONY: build release run sim test package dev-device all-devices sdk-link clean help

## build: compile a debug .prg for $(DEVICE)
build: | $(BIN)
	monkeyc -f $(JUNGLE) -o $(PRG) -y $(KEY) -d $(DEVICE) -w -l $(TYPECHECK)

## release: compile a release .prg (debug info stripped) for $(DEVICE)
release: | $(BIN)
	monkeyc -f $(JUNGLE) -o $(PRG) -y $(KEY) -d $(DEVICE) -w -r -l $(TYPECHECK)

## sim: start the Connect IQ simulator if it is not already running
sim:
	@if pgrep -x simulator >/dev/null 2>&1; then \
		echo "simulator already running"; \
	else \
		echo "starting simulator (log: $(CONNECTIQ_LOG))"; \
		setsid connectiq >$(CONNECTIQ_LOG) 2>&1 </dev/null & \
		for i in $$(seq 1 30); do \
			pgrep -x simulator >/dev/null 2>&1 && break; \
			sleep 0.5; \
		done; \
	fi

## run: build then push and run on the simulator
# monkeydo can't connect for a moment after the simulator process appears
# (and the process can crash on first launch under X), so retry a few times.
run: sim build
	@for i in $$(seq 1 10); do \
		monkeydo $(PRG) $(DEVICE) && exit 0; \
		echo ">> simulator not ready, retry $$i"; sleep 1; \
	done; \
	echo ">> could not reach the simulator"; exit 1

## test: build the unit tests and run them on the simulator
# monkeydo exits non-zero even when tests pass, so key the result off the
# runner's summary line instead; retry while it can't reach the simulator.
test: sim | $(BIN)
	monkeyc -f $(TEST_JUNGLE) -o $(TEST_PRG) -y $(KEY) -d $(DEVICE) -t -w -l $(TYPECHECK)
	@for i in $$(seq 1 10); do \
		out=$$(monkeydo $(TEST_PRG) $(DEVICE) -t 2>&1); \
		echo "$$out" | grep -q 'Unable to connect to simulator' || break; \
		echo ">> simulator not ready, retry $$i"; sleep 1; \
	done; \
	echo "$$out"; \
	echo "$$out" | grep -q '^PASSED' || { echo ">> tests did not pass"; exit 1; }

## package: build the store .iq (run `make all-devices` first)
package:
	monkeyc -e -f $(JUNGLE) -o $(IQ) -y $(KEY) -w -r -l $(TYPECHECK)

## dev-device: download just $(DEVICE)'s simulator files
dev-device:
	$(SDK_MANAGER) device download -d $(DEVICE) -F

## all-devices: download every device in manifest.xml (many GB)
all-devices:
	$(SDK_MANAGER) device download -m manifest.xml -F

## sdk-link: point ~/.local/ciq-sdk at the currently active SDK
sdk-link:
	ln -sfn "$$($(SDK_MANAGER) sdk current-path)" "$(HOME)/.local/ciq-sdk"

## clean: remove build output
clean:
	rm -rf $(BIN) build $(IQ)

$(BIN):
	@mkdir -p $(BIN)

## help: list targets
help:
	@grep -hE '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'
