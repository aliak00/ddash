module common;

version (unittest) {
    public import std.stdio;
    public import std.algorithm.comparison: equal;
}

public template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}
