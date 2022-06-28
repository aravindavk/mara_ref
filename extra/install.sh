#!/bin/bash

curl -fsSL https://github.com/aravindavk/mara/releases/latest/download/mara-`uname -m | sed 's|aarch64|arm64|' | sed 's|x86_64|amd64|'` -o /tmp/mara

install /tmp/mara /usr/bin/mara
