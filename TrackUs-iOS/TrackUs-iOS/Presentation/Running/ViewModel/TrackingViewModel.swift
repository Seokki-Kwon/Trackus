//
//  TrackingViewModel.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/6/24.
//

import Foundation
import Combine
import MapKit

final class TrackingViewModel: ViewModelable {
    
    // MARK: - Properties
    
    enum Action {
        case startButtonTap
        case stopButtonTap
        case pauseButtonTap
        case saveButtonTap
    }
    
    struct State {
        let isTrackingMode = CurrentValueSubject<Bool, Never>(false)
        let totalTime = CurrentValueSubject<Double, Never>(0)
        let currentDistance = CurrentValueSubject<Double, Never>(0)
        let currentPace = CurrentValueSubject<Double, Never>(0)
        let coordinates = CurrentValueSubject<[CLLocation], Never>([])
        let recordData = CurrentValueSubject<Record?, Never>(nil)
    }
    
    // State
    public var state = State()
    private var beforeDistance = 0.0
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    // Dependency
    private let coreMotionService: CoreMotionServiceType
    private let locationService: LocationService
    private let recordRepository: RecordRepositoryType
    
    init(recordRepository: RecordRepositoryType) {
        self.coreMotionService = CoreMotionService.shared
        self.locationService = LocationService.shared
        self.recordRepository = recordRepository
    }
    
}

// MARK: - Action
extension TrackingViewModel {
    func send(_ action: Action) {
        switch action {
        case .startButtonTap:
            startTracking()
        case .pauseButtonTap:
            stopTracking()
        case .stopButtonTap:
            stopTracking()
        case .saveButtonTap:
            uploadRecordData()
        }
    }
    
    func startTracking() {
        state.isTrackingMode.send(true)
        startTimer()
        startRecord()
        startLocationUpdate()
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

extension TrackingViewModel: UserLocationDelegate {
    func userLocationUpated(location: CLLocation) {
        state.coordinates.send(state.coordinates.value + [location])
    }
    
    // 위치 업데이트
    private func startLocationUpdate() {
        locationService.allowBackgroundUpdates = true
        locationService.userLocationDelegate = self
    }
    
    private func stopLocationUpdate() {
        locationService.allowBackgroundUpdates = false
        locationService.userLocationDelegate = nil
    }
}

// MARK: - Firebase
extension TrackingViewModel {
    func uploadRecordData() {
        let uploadRecord = Record(distance: state.currentDistance.value, 
                                  pace: state.currentPace.value,
                                  totalTime: state.totalTime.value)
        
        recordRepository.uploadRecord(uploadRecord)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("완료")
                case .failure(let error):
                    print("실패")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
