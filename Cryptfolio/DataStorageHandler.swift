//
//  DataStorageHandler.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-13.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class UserManager {
	
	public static let shared = UserManager();
	
	public func getCurrentProfilePicture() -> UIImage? {
		if let encodedimage = UserDefaults.standard.string(forKey: "profilePicture") {
			return DataStorageHandler.decodeImage(strBase64: encodedimage);
		}
		return nil;
	}
	
	public func setCurrentProfilePicture(image:UIImage) -> Void {
		let encodedImage = DataStorageHandler.encodeImage(image: image);
		UserDefaults.standard.set(encodedImage, forKey: "profilePicture");
	}
	
	public func removeCurrentProfilePicture() -> Void {
		UserDefaults.standard.removeObject(forKey: "profilePicture");
	}
	
	public func getCurrentUsername() -> String? {
		return UserDefaults.standard.string(forKey: UserDefaultKeys.currentUsername);
	}
	
	public func setCurrentUsername(username:String) -> Void {
		UserDefaults.standard.set(username, forKey: UserDefaultKeys.currentUsername);
	}
	
	public func removeCurrentUsername() -> Void {
		UserDefaults.standard.removeObject(forKey: UserDefaultKeys.currentUsername);
	}
	
}


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
	
	public static func encodeImage(image:UIImage?) -> String {
		guard let image = image else { return ""; }
		if let imageData:Data = image.jpegData(compressionQuality: 1) {
			let strBase64 = imageData.base64EncodedString();
			return strBase64;
		}
		return "";
	}
	
	public static func decodeImage(strBase64:String) -> UIImage? {
		let newImageData = Data(base64Encoded: strBase64);
		if let newImageData = newImageData { return UIImage(data: newImageData); }
		return nil;
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
