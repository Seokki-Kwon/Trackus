//
//  TrackingViewModel.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/6/24.
//

import Foundation
import Combine


final class TrackingViewModel: ViewModelable {
    
    // MARK: - Properties
    
    enum Action {
        case startButtonTap
        case stopButtonTap
    }
    
    struct State {
        let isTrackingMode = CurrentValueSubject<Bool, Never>(false)
        let totalTime = CurrentValueSubject<Double, Never>(0)
        let currentDistance = CurrentValueSubject<Double, Never>(0)
        let currentPace = CurrentValueSubject<Double, Never>(0)
    }
    
    public var state = State()
    
    private var beforeDistance = 0.0
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    private let coreMotionService: CoreMotionServiceType
    
    init() {
        self.coreMotionService = CoreMotionService.shared
    }
    
}

// MARK: - Action
extension TrackingViewModel {
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
        startTimer()
        startRecord()
    }
    
    func stopTracking() {
        state.isTrackingMode.send(false)
        stopTimer()
        stopRecord()
    }
}

// MARK: - Helper
extension TrackingViewModel {
    
    // 타이머 시작
    private func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .withUnretained(self)
            .sink { (owner, _) in
                let newCount = owner.state.totalTime.value + 1
                owner.state.totalTime.send(newCount)
            }
        
        timer?.store(in: &cancellables)
    }
    
    // 타이머 종료
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // 기록 시작
    private func startRecord() {
        coreMotionService.startUpdate(from: .now) { [weak self] value in
            guard let value = value,
                let self = self else { return }
            
            let currentTime = state.totalTime.value
            let currentDistance = state.currentDistance.value
            let pace = (currentTime / 60) / (currentDistance / 1000.0)
        
            state.currentDistance.send(beforeDistance + value)
            state.currentPace.send(pace)
        }
    }
    
    // 기족 종료
    private func stopRecord() {
        coreMotionService.stopUpdate()
        beforeDistance = state.currentDistance.value
    }
}
