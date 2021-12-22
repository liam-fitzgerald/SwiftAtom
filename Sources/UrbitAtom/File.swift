//
//  File.swift
//  
//
//  Created by Liam Fitzgerald on 1/12/21.
//

import Foundation
import BigInt

extension BigUInt {
    func asBytes() -> [UInt8] {
        var bytes: [UInt8] = [];
        var copy = self;
        let mask = BigUInt(255);
        while(copy != BigUInt.zero) {
            bytes.append(UInt8(mask & copy));
            copy >>= 8;
        }
        return bytes;
        
    }
}
