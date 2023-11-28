#!/bin/bash
gcc -o cordic -std=c99 cordic.c -lm
./cordic $@
