import os
import sys
import math
import inspect
from gen_rtl import float_to_fixed, fixed_to_float, int_to_bin, int_to_hex

if len(sys.argv) != 3:
    print("Usage: python3 convert.py [type=float/hex/bin] [value]")

input_type = sys.argv[1]
value = sys.argv[2]

if input_type == "float":
    float_value = float(value)
    fixed_value = float_to_fixed(float_value)
    hex_fixed = int_to_hex(fixed_value)
    bin_fixed = int_to_bin(fixed_value)
elif input_type == "hex":
    fixed_value = int(value.split("h")[-1], 16)
    float_value = fixed_to_float(fixed_value)
    hex_fixed = int_to_hex(fixed_value)
    bin_fixed = int_to_bin(fixed_value)
elif input_type == "bin":
    fixed_value = int(value.split("b")[-1], 2)
    float_value = fixed_to_float(fixed_value)
    hex_fixed = int_to_hex(fixed_value)
    bin_fixed = int_to_bin(fixed_value)
else:
    print(f"Invalid type: {input_type}, must be one of float, hex, or bin")

print(f"float: {float_value}, hex: {hex_fixed}, bin: {bin_fixed}")

