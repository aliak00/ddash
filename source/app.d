import std.stdio;
import std.functional, std.algorithm, std.range, std.array;
import common: from;

void main() {
    import algorithm: findIndex;
    [1, 2].findIndex(1).writeln;
    // from!"benchmarks.intersection".profile!();
}
