//
//  RecordRepository.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/7/24.
//

import Combine

final class TestRecordRepository: RecordRepositoryType {
    func uploadRecord(_ record: Record) -> AnyPublisher<Void, Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    func fetchRecord() -> AnyPublisher<[Record], Never> {
        var makeTestData: [Record] {
            var testData: [Record] = []
            [1...10].forEach { _ in
                testData.append(Record(distance: Double.random(in: 10...1000),
                                       pace: Double.random(in: 10...100),
                                       totalTime: Double.random(in: 10...1000)))
            }
            return testData
        }
        return Just(makeTestData).eraseToAnyPublisher()
    }
}
