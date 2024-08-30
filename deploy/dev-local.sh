#!/bin/bash

# Panggil skrip symlink.sh dari direktori saat ini
bash ./symlink.sh --force

# Panggil skrip wrapper.sh dari direktori saat ini
bash ./wrapper.sh dev-local down
bash ./wrapper.sh dev-local up
