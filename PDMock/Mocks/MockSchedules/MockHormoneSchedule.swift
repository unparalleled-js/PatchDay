//
// Created by Juliya Smith on 2/11/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormoneSchedule: HormoneScheduling {

	public var all: [Hormonal] = []
	public var isEmpty: Bool = false
	public var next: Hormonal? = nil
	public var totalExpired: Int = -1
	public var count: Int = -1

	public var fillInCallArgs: [Int] = []
	public var deleteCallArgs: [Index] = []
	public var shareDataCallCount = 0

	public init() { }

	public var insertNewReturnValue: Hormonal? = nil
	public func insertNew() -> Hormonal? {
		insertNewReturnValue
	}

	public func reset(completion: (() -> ())?) -> Int {
        -1
	}

	public func saveAll() {

	}

	public func delete(after i: Index) {
		deleteCallArgs.append(i)
	}

	public func deleteAll() {

	}

	public subscript(index: Index) -> Hormonal? {
        all.tryGet(at: index)
	}

	public subscript(id: UUID) -> Hormonal? {
		nil
	}

	public var setByIdCallArgs: [(UUID, Date, Bodily, Bool)] = []
	public func set(by id: UUID, date: Date, site: Bodily, incrementSiteIndex: Bool) {
		setByIdCallArgs.append((id, date, site, incrementSiteIndex))
	}

	public var setByIndexCallArgs: [(Index, Date, Bodily, Bool)] = []
	public func set(at index: Index, date: Date, site: Bodily, incrementSiteIndex: Bool) {
		setByIndexCallArgs.append((index, date, site, incrementSiteIndex))
	}

	public var setSiteByIdCallArgs: [(UUID, Bodily, Bool)] = []
	public func setSite(by id: UUID, with site: Bodily, incrementSiteIndex: Bool) {
		setSiteByIdCallArgs.append((id, site, incrementSiteIndex))
	}

	public var setSiteByIndexCallArgs: [(Index, Bodily, Bool)] = []
	public func setSite(at index: Index, with site: Bodily, incrementSiteIndex: Bool) {
		setSiteByIndexCallArgs.append((index, site, incrementSiteIndex))
	}

	public var setDateByIdCallArgs: [(UUID, Date)] = []
	public func setDate(by id: UUID, with date: Date) {
		setDateByIdCallArgs.append((id, date))
	}

	public var setDateByIndexCallArgs: [(Index, Date)] = []
	public func setDate(at index: Index, with date: Date) {
		setDateByIndexCallArgs.append((index, date))
	}

	public var indexOfCallArgs: [Hormonal] = []
	public var indexOfReturnValue: Index? = nil
	public func indexOf(_ hormone: Hormonal) -> Index? {
		indexOfCallArgs.append(hormone)
		return indexOfReturnValue
	}

	public func fillIn(to stopCount: Int) {
		fillInCallArgs.append(stopCount)
	}

	public func shareData() {
		shareDataCallCount += 1
	}

	public func sort() {

	}

	public func reset() -> Int {
        -1
	}
}
