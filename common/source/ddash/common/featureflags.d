module ddash.common.featureflags;

package(ddash) struct FeatureFlag {
    enum tryUntil = __VERSION__ > 2087L;
}
