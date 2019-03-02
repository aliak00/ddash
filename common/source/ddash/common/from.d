module ddash.common.from;

private template CanImport(string moduleName) {
    enum CanImport = __traits(compiles, { mixin("import ", moduleName, ";"); });
}

private template ModuleContainsSymbol(string moduleName, string symbolName) {
    enum ModuleContainsSymbol = CanImport!moduleName && __traits(compiles, {
        mixin("import ", moduleName, ":", symbolName, ";");
    });
}

private struct FromImpl(string moduleName) {
    template opDispatch(string symbolName) {
        static if (ModuleContainsSymbol!(moduleName, symbolName)) {
            mixin("import ", moduleName,";");
            mixin("alias opDispatch = ", symbolName, ";");
        } else {
            static if (moduleName.length == 0) {
                enum opDispatch = FromImpl!(symbolName)();
            } else {
                enum importString = moduleName ~ "." ~ symbolName;
                static assert(
                    CanImport!importString,
                    "Symbol \"" ~ symbolName ~ "\" not found in " ~ modueName
                );
                enum opDispatch = FromImpl!importString();
            }
        }
    }
}

enum from = FromImpl!null();
