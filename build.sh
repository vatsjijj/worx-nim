#!/bin/sh

nimble build --deepcopy:on --mm:arc --opt:speed --stackTrace:off -a:off -x:off -d:release --cc:clang --passC:-Ofast --passC:-fomit-frame-pointer --passC:-DNDEBUG