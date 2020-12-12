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
    
    public static func encodeTypeIntoJSON<T : Codable>(type: T) -> Array<Dictionary<String, Any>>? {
        let encoder = JSONEncoder();
        if let encoded = try? encoder.encode(type) {
            do {
                if let json = try JSONSerialization.jsonObject(with: encoded, options: []) as? Array<Dictionary<String, Any>> {
                    return json;
                }
            } catch let error as NSError {
                print(error.localizedDescription);
                return nil;
            }
        } else {
            return nil;
        }
        return nil;
    }
    
    public static func decodeTypeFromJSON<T : Codable>(type: T.Type, jsonData: Array<Dictionary<String, Any>>) -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted) {
            let decoder = JSONDecoder();
            if let decoded = try? decoder.decode(type, from: data) {
                return decoded;
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    
    
}
