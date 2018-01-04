import std.stdio;
import std.typecons;

import algorithm: fromPairs;

alias Pair = Tuple!(int, int);

void main() {
    Pair[] a = [Pair(3, 4), Pair(1, 2)];
    a.fromPairs.writeln;
}
