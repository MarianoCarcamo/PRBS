# PRBS Generator

This repository provides a **PRBS (Pseudo-Random Binary Sequence)** generator along with a Python model to generate PRBS samples with configurable polynomials, parallelism, and seed values.

---

## Installation

Clone the repository and make sure it is on your Python path:

```bash
git clone https://github.com/<your-username>/prbs.git
cd prbs
```

## Basic Usage

Create a PRBS generator by importing the PRBS class and calling the create factory method:
```bash
import numpy as np
from prbs import PRBS

prbs = PRBS.create(PRBS_taps, parallelism, seed_taps)
```

### Parameters
- PRBS_taps:
Defines the feedback taps of the PRBS polynomial.

Example:
PRBS3 polynomial. "PRBS_taps = [3, 2]"

- parallelism:
Number of bits generated per sample.

Example:
parallelism = 8  # 8 bits per output sample

- seed_taps: 
Initial seed of the PRBS shift register.

⚠️ Important:
The seed must contain at least one 1. An all-zero seed will lock the PRBS and prevent sequence generation.
For a PRBS of order N, the seed must have length N.

Example (PRBS3):
seed_taps = [2, 0]
This initializes a 3-bit shift register with at least one active bit.

### Generating Samples

Once the PRBS object is created, generate samples using:

```bash
sample = prbs.get_sample()
```

Each call to get_sample() returns one PRBS output sample with the specified parallelism.
Example:
```bash
from prbs import PRBS

PRBS_taps = [3, 2]
parallelism = 3
seed_taps = [2, 0]

prbs = PRBS.create(PRBS_taps, parallelism, seed_taps)

sample = prbs.get_sample()
print(sample)
```

Notes:\
The generator follows standard PRBS/LFSR behavior.
Parallel output allows multiple bits to be generated per cycle.
Suitable for modeling, simulation, and verification workflows.