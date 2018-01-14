import std.stdio;
import std.functional, std.algorithm, std.range, std.array;
import common: from;

void main() {
    from!"benchmarks.difference".profile!();
}
