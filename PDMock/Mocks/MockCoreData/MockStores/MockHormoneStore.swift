//
//  MockHormonesStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormoneStore: HormoneStoring, PDMocking {
    
    public var getStoredHormonesReturnValues: [[Hormonal]] = []
    public var createNewHormoneReturnValues: [Hormonal] = []
    private var deleteCallArgs: [Hormonal] = []
    private var pushLocalChangesCallArgs: [([Hormonal], Bool)] = []
    
    public init() {}
    
    public func resetMock() {
        getStoredHormonesReturnValues = []
        createNewHormoneReturnValues = []
        deleteCallArgs = []
    }
    
    public func getStoredHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        if let mockHormoneList = getStoredHormonesReturnValues.first {
            getStoredHormonesReturnValues.remove(at: 0)
            return mockHormoneList
        }
        return []
    }
    
    public func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        if let hormone = createNewHormoneReturnValues.first {
            createNewHormoneReturnValues.remove(at: 0)
            return hormone
        }
        return nil
    }
    
    public func delete(_ hormone: Hormonal) {
        deleteCallArgs.append(hormone)
    }
    
    public func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }
}
