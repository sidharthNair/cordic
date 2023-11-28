import os
import sys
import math
import inspect

def float_to_fixed(float):
    return int(float * (1 << 30))

def fixed_to_float(fixed):
    return float(fixed) / (1 << 30)

def int_to_hex(value, bits=32):
    hex_str = hex(value)[2:]
    hex_str = "0" * (int(math.ceil(bits / 4)) - len(hex_str)) + hex_str
    return f"{bits}'h{hex_str}"

def int_to_bin(value, bits=5):
    bin_str = bin(value)[2:]
    bin_str = "0" * (bits - len(bin_str)) + bin_str
    return f"{bits}'b{bin_str}"

try:
    num_terms = int(sys.argv[1])
except Exception:
    print("Usage: python3 gen_rtl.py [num_terms]")
    exit(1)

script_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
template = f"{script_dir}/template/cordic.v"
output = f"{script_dir}/cordic_{num_terms}.v"

atan = []
gain = 1.0
for i in range(num_terms):
    phi = math.atan(pow(2, -1 * i))
    gain *= math.cos(phi)
    atan.append(float_to_fixed(phi))
fixed_gain = float_to_fixed(gain)

def gen_table(atan, prefix="    "):
    table = ""
    for i, angle in enumerate(atan):
        table += f"{prefix}assign atan[{i}]\t= {int_to_hex(angle)};\n"
    return table[:-1]

def gen_cordic_blocks(num_terms, prefix="    "):
    blocks = ""
    for i in range(num_terms):
        x_out = "cos_out" if i+1 == num_terms else f"x[{i+1}]"
        y_out = "sin_out" if i+1 == num_terms else f"y[{i+1}]"
        blocks += f"{prefix}cordic_block c{i}(.x_in(x[{i}]), .y_in(y[{i}]), .theta_in(t[{i}]), .atan(atan[{i}]), .i({int_to_bin(i)}), .x_out({x_out}), .y_out({y_out}), .theta_out(t[{i+1}]));\n"
    return blocks[:-1]

atan_table = gen_table(atan)
cordic_blocks = gen_cordic_blocks(num_terms)

with open(template, 'r') as t:
    data = t.read()
    data = data.replace("__TERMS__", str(num_terms))
    data = data.replace("__ASSIGN_ATAN__", atan_table)
    data = data.replace("__GAIN__", int_to_hex(fixed_gain))
    data = data.replace("__CORDIC_BLOCKS__", cordic_blocks)
    with open(output, "w") as o:
        o.write(data)

print(f"Generated {output} from template file: {template}")
