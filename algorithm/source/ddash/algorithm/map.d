module ddash.algorithms.map;

import ddash.lang.range;

struct MappedRange(alias mapper, Range) {
    Range range;

    bool empty() @property inout {
        return range.empty;
    }
    auto front() @property inout {
        return mapper(range.front);
    }
    void popFront() {
        range.popFront();
    }

    auto opHeadMutable(this This)() const {
        return MappedRange!(mapper, HeadMutableOf!(Range, This))(range.opHeadMutable());
    }
}

auto map(alias mapper, Range)(auto ref Range range) if (isInputRange!Range) {
    return MappedRange!(mapper, ResolvedHeadMutable!Range)(range.resolveOpHeadMutable);
}

struct FivePrimesSequence {
    int[] data = [1, 3, 5, 7, 11, 13];
    int index = 0;
    bool empty() @property const {
        return index == data.length;
    }
    auto front() @property const {
        return data[index];
    }
    void popFront() {
        index++;
    }
    auto opHeadMutable(this This)() const {
        return FivePrimesSequence(data.dup, index);
    }
}

@("testing")
unittest {
    import std.stdio: writeln;
    import std.algorithm: equal;
    import std.range: array;

    // import std.meta;

    // foreach (T; AliasSeq!(int, const int, immutable int)) {
    //     T[] arr = [1, 2, 3];
    //     auto a = arr.map!(a => a * 2);
    //     const ca = arr.map!(a => a * 2);
    //     immutable ia = ca.mutable.map!(a => a * 2);

    //     assert(a.mutable.equal([2, 4, 6]));
    //     assert(ca.mutable.equal([2, 4, 6]));
    //     assert(ia.mutable.equal([2, 4, 6]));

    //     auto primies = CopyTypeQualifiers!(T, FivePrimesSequence)();
    //     primes.mutable.writeln;
    // }


    auto arr = [1, 2, 3];
    const cm = arr.map!(a => a);
    const cm2 = cm.map!(a => a);

    writeln(arr is cm.range);

    writeln(cm.mutable);
    // assert(cm2.mutable.equal(arr));

    // const a = FivePrimesSequence();
    // const b = a.map!(a => a * 2);

    // writeln(b.mutable);

    // b.front.writeln;
}
