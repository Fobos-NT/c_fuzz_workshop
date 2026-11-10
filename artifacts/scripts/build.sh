#! /bin/bash
cd /home/fuzzer/json-parser-1.1.0
mkdir /home/fuzzer/json-parser-1.1.0/fuzz/
make clean

#sydr build
CC=clang CFLAGS="" ./configure && make libjsonparser.a
mkdir sydr_build && cp libjsonparser.a sydr_build
make clean

# afl++ build
CC=afl-clang-lto ./configure && make libjsonparser.a
mkdir afl_build && cp libjsonparser.a afl_build
make clean

# asan build
CC=afl-clang-lto CFLAGS="-fsanitize=address" ./configure && make libjsonparser.a
mkdir asan_build && cp libjsonparser.a asan_build
make clean

# ubsan build
CC=afl-clang-lto CFLAGS="-fsanitize=undefined" ./configure && make libjsonparser.a
mkdir ubsan_build && cp libjsonparser.a ubsan_build
make clean

#libfuzzer build
CC=clang CFLAGS="-fsanitize=address,undefined,fuzzer-no-link" ./configure && make libjsonparser.a
mkdir libfuzzer_build && cp libjsonparser.a libfuzzer_build
make clean

# cov build
CC=clang CFLAGS="-fprofile-instr-generate -fcoverage-mapping" ./configure && make libjsonparser.a
mkdir cov_build && cp libjsonparser.a cov_build
make clean

cd /home/fuzzer/artifacts
# afl++ build
afl-clang-lto json_parse.c -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/afl_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/afl_fuzz

# asan build
afl-clang-lto json_parse.c -fsanitize=address -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/asan_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/asan_fuzz

# ubsan build
afl-clang-lto json_parse.c -fsanitize=undefined -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/ubsan_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/ubsan_fuzz

#libfuzzer build
clang json_parse_libfuzzer.c -fsanitize=undefined,address,fuzzer -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/libfuzzer_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/libfuzzer_fuzz

#sydr build
clang json_parse.c -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/sydr_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/sydr_fuzz

# cov build
clang json_parse.c -fprofile-instr-generate -fcoverage-mapping -I/home/fuzzer/json-parser-1.1.0 -L/home/fuzzer/json-parser-1.1.0/cov_build/ -ljsonparser -lm -o /home/fuzzer/json-parser-1.1.0/fuzz/cov_fuzz
