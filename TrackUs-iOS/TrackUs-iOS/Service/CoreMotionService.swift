//
//  CoreMotionService.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/7/24.
//

import Foundation
import CoreMotion

protocol CoreMotionServiceType {
    func checkAuthrization(completion: @escaping (CoreMotionService.AuthrizationStatus) -> Void)
    func startUpdate(from date: Date, completion: @escaping (Double?) -> ())
    func stopUpdate()
}

final class CoreMotionService: CoreMotionServiceType {
    
    enum AuthrizationStatus {
        case authorized
        case denied
    }
    
    static let shared = CoreMotionService()
    
    private let pedometer = CMPedometer()
    private let altimeter = CMAltimeter()
    
    private init() {}
    
    /// 동작감지 허용여부 확인
    func checkAuthrization(completion: @escaping (AuthrizationStatus) -> Void) {
        if CMPedometer.authorizationStatus() == .authorized {
            completion(.authorized)
        } else if CMPedometer.authorizationStatus() == .notDetermined {
            pedometer.startEventUpdates { (_, _) in}
        } else {
            completion(.denied)
        }
    }
    
    ///  뷰모델에 필요한 값을 보낸다
    func startUpdate(from date: Date, completion: @escaping (Double?) -> ()) {        
        pedometer.startUpdates(from: date) { pedometerData, error in
            
            guard let pedometerData = pedometerData, error == nil else {
                completion(nil)
                return
            }
            
            let currentDistance = pedometerData.distance?.doubleValue ?? 0.0
            
            completion(currentDistance)
        }
    }
    
    func stopUpdate() {
        pedometer.stopUpdates()
    }
}
