//
//  TrackingViewModel.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/6/24.
//

import Foundation
import Combine


final class TrackingViewModel: ViewModelable {
    
    enum Action {
        case startButtonTap
        case stopButtonTap
    }
    
    struct State {
        let isTrackingMode = CurrentValueSubject<Bool, Never>(false)
        let elapsedTime = CurrentValueSubject<Double, Never>(0)
    }
    
    public var state = State()
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    func send(_ action: Action) {
        switch action {
        case .startButtonTap:
            startTracking()
        case .stopButtonTap:
            stopTracking()
        }
    }
    
    func startTracking() {
        state.isTrackingMode.send(true)
        guard timer == nil else { return }
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .withUnretained(self)
            .sink { (owner, _) in
                let newCount = owner.state.elapsedTime.value + 1
                owner.state.elapsedTime.send(newCount)
            }
        
        timer?.store(in: &cancellables)
    }
    
    func stopTracking() {
        timer?.cancel()
        timer = nil
        state.isTrackingMode.send(false)
    }
}
