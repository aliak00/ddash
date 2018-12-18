module ddash.common;

template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

version (unittest) {
    package(ddash) import std.array;
    package(ddash) import std.typecons: Yes, No;
    package(ddash) import std.stdio: writeln;
    package(ddash) import ddash.common.equal;
}
