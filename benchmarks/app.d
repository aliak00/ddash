
void main() {
    static import ddash.benchmarks.concat;
    static import ddash.benchmarks.match;
    static import ddash.benchmarks.difference;
    static import ddash.benchmarks.intersection;
    static import ddash.benchmarks.pullat;
    ddash.benchmarks.concat.profile!();
    ddash.benchmarks.match.profile!();
    ddash.benchmarks.difference.profile!();
    ddash.benchmarks.intersection.profile!();
    ddash.benchmarks.pullat.profile!();
}
