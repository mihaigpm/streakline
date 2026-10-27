import Foundation
import SwiftData

/// The one programme row. Shield inventory lives here so a later sync can see it.
/// Created the first time a finished week earns a shield. Cap is 1.
@Model
final class ProgrammeState {
    var shieldsAvailable: Int = 0

    init(shieldsAvailable: Int = 0) {
        self.shieldsAvailable = shieldsAvailable
    }
}
