//
//  DataStorageHandler.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-13.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class DataStorageHandler {
    
    public static func loadObject<T : Codable>(type: T.Type, forKey:String) -> T? {
        if let savedObject = UserDefaults.standard.object(forKey: forKey) as? Data {
            let decoder = JSONDecoder();
            if let loadedObject = try? decoder.decode(type, from: savedObject) {
                return loadedObject;
            }
        } else {
            return nil
        }
        return nil;
    }
    
    public static func saveObject<T : Codable>(type: T, forKey: String) {
        let encoder = JSONEncoder();
        if let encoded = try? encoder.encode(type) {
            UserDefaults.standard.set(encoded, forKey: forKey);
        }
    }
    
    
}
