import std.stdio;

import algorithm: flatMap;

void main() {
    [1, 2, 3].flatMap!(a => a).writeln;
}
