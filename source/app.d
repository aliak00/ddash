import std.stdio;
import std.functional, std.algorithm, std.range, std.array;
import common, algorithm;

void main() {
    from!"benchmarks.intersection".profile!();
}
