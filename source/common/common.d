module common;

public template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

version (unittest) {
    public import std.stdio;
    public import algorithm.equal;
    public import std.array;
    public import std.typecons: Yes, No;
}
