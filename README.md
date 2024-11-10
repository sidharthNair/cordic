# cordic

This project explores the hardware implementation of complex arithmetic functions, specifically using the
CORDIC algorithm. This algorithm has been found to leverage
clever lightweight hardware calculation to approximate functions
that are generally considered slow. We use Verilog to create the
CORDIC algorithm and a Taylor series accelerator to calculate
sine and cosine and synthesize a gate-level schematic and physical
layout for the modules to more accurately measure the power,
performance, and area (PPA) to compare these implementations
for different accuracy levels and other constraints.

[`Project Report`](https://github.com/sidharthNair/cordic/blob/main/README.pdf)
