import std.stdio;
import common: from;

void main() {
    from!"benchmarks.difference".profile();
}
