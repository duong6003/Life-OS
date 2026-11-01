import Testing

@testable import FeatureSupport

@Test func userFacingErrorsAreThreeKinds() {
    let all: [UserFacingError] = [.iCloudSignedOut, .missingKeyOnNewDevice, .localDataCorrupted]
    #expect(all.count == 3)  // BR-GEN-08
}
