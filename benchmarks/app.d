
void main() {
    static import ddash.benchmarks.concat;
    static import ddash.benchmarks.cond;
    static import ddash.benchmarks.difference;
    static import ddash.benchmarks.intersection;
    static import ddash.benchmarks.pullIndices;
    ddash.benchmarks.concat.profile!();
    ddash.benchmarks.cond.profile!();
    ddash.benchmarks.difference.profile!();
    ddash.benchmarks.intersection.profile!();
    ddash.benchmarks.pullIndices.profile!();
}
