import std.stdio;
import std.functional, std.algorithm, std.range, std.array, std.traits, std.meta;
import common, algorithm;

void main() {
    import benchmarks.cond;
    profile!();
}
