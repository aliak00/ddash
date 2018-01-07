module utils.allpairs;

import std.range: isInputRange;

auto allPairs(Range)(Range range) if (isInputRange!Range) {
    static struct Result {
        import std.range: ElementType, dropOne;
        import std.traits: isArray;
        static if (isArray!Range) {
            import std.array;
        }

        Range r1, r2;

        this(Range range) {
            this.r1 = range;
            this.r2 = range.dropOne;
        }

        auto front() @property pure {
            return [this.r1.front, this.r2.front];
        }
        bool empty() @property pure {
            return this.r1.dropOne.empty;
        }
        void popFront() {
            if (this.r2.dropOne.empty) {
                this.r1.popFront;
                this.r2 = this.r1;
            }
            this.r2.popFront;
        }
    }

    return Result(range);
}

unittest {
    import std.array;
    assert([1, 2, 3].allPairs.array == [[1, 2], [1, 3], [2, 3]]);
}
