#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math

with open('256-colors.tsv') as fp:
    data = [
        v.split('\t')
        for v in fp.read().splitlines()
    ]

def scale(cc: int) -> int:
    return int(math.ceil((cc / 255) * 15))

rgb32 = [(int(v[0]), int(v[2][1:], 16)) for v in data]
rgbch = [(i, c >> 16, (c >> 8) & 0xff, c & 0xff) for i, c in rgb32]
adjch = [(i, scale(r), scale(g), scale(b)) for i, r, g, b in rgbch]
rgb12 = [(i, (r << 8) | (g << 4) | b) for i, r, g, b in adjch]
lut12 = ["8'b%s: pbuf <= 12'b%s;" % (format(i, '08b'), format((r << 8) | (g << 4) | b, '012b')) for i, r, g, b in adjch]

for line in lut12:
    print(line)
