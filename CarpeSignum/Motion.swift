import Foundation
import CoreMotion

/// Bonusteknik: styr gränssnittet med telefonen, minus skärmen (gyro).
/// Känner av när telefonen ligger med skärmen nedåt.
@Observable
final class MotionWatcher {
    private(set) var isFaceDown = false
    private let manager = CMMotionManager()

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 0.1
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let gravity = motion?.gravity else { return }
            // z är nära +1 när skärmen pekar mot bordet, nära −1 när den pekar uppåt.
            // Två olika gränser så att det inte fladdrar fram och tillbaka.
            if !self.isFaceDown, gravity.z > 0.8 {
                self.isFaceDown = true
            } else if self.isFaceDown, gravity.z < 0.3 {
                self.isFaceDown = false
            }
        }
    }
}
