module ddash.common.featureflags;

struct FeatureFlag {
    enum tryUntil = __VERSION__ > 2087L;
}
