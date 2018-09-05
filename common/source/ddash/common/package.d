module ddash.common;

template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

version (unittest) {
    public import std.array;
    public import std.typecons: Yes, No;
    public import std.stdio: writeln;
    public import ddash.common.equal;
}
