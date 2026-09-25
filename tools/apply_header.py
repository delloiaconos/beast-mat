#!/usr/bin/env python3

from pathlib import Path
import re

ROOT = Path(".")

HEADER = """% BEAST - Battery Estimation Algorithms and Simulation Toolkit
%
% This file is part of the BEAST MATLAB implementation.
%
% Project:
%   Battery Estimation Algorithms and Simulation Toolkit (BEAST)
%
% Repository:
%   https://github.com/delloiaconos/beast-mat
%
% Copyright (C) 2026 Salvatore Dello Iacono
% SPDX-License-Identifier: GPL-3.0-or-later
%
% See the LICENSE file in the project repository for license information.
%
% NOTE: Detailed file documentation is to be added as the implementation matures.

"""

for path in ROOT.rglob("*.m"):
    text = path.read_text(encoding="utf-8")

    # Remove an existing BEAST header at the beginning of the file.
    #
    # It looks for a leading MATLAB comment block containing "BEAST"
    # and removes only that block.
    match = re.match(
        r"\A((?:[ \t]*%[^\n]*\n|[ \t]*\n)+)",
        text
    )

    if match and "BEAST" in match.group(1):
        text = text[match.end():].lstrip("\n")

    path.write_text(HEADER + text, encoding="utf-8")

    print(path)