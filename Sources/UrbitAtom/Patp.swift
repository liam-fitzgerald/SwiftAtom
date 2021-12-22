//
//  File.swift
//  
//
//  Created by Liam Fitzgerald on 1/12/21.
//

import Foundation
import Parsing
import BigInt

enum PatpClan: Int, Codable {
    case pawn = 4, king = 1, duke = 2, earl = 3, czar = 0;
}

fileprivate func rendSyl(_ fst: UInt8, _ snd: UInt8) -> String {
    return "\(Pfix(byte: fst))\(Sfix(byte: snd))";
}

fileprivate func scotNoSig(_ byts: [UInt8]) -> String {
    var res = "";
    var i = 0;
    var j = 0;
    while(byts.count != i) {
        j += 1;
        let sep = i == 0 ? "" : (j % 4) == 0 ? "--" : "-";
        res += sep;
        res += rendSyl(byts[i], byts[i+1]);
        i += 2;
    }
    return res;
}


struct Patp: Aura, Codable {
    var value: BigUInt;
    
    init?(fromString: String) {
        guard let result = PointParser().parse(fromString) else {
            return nil;
        }
        value = result;
    }
    init(from decoder: Decoder) {
        let container = try! decoder.singleValueContainer();
        let str = try! container.decode(String.self);
        self.init(fromString: str)!;
    }
    
    var shouldObfuscate: Bool {
        switch(clan) {
        case .earl, .duke:
            return true;
        default:
            return false;
        }
    }
    
    var scot: String {
        let val = shouldObfuscate ? Ob.obfuscate(value) : value;
        let byts: [UInt8] = val.asBytes().reversed();
        return "~\(scotNoSig(byts))"
    }
    
    var clan: PatpClan {
        let met = value.bitWidth;
        switch(met) {
        case 0...8:
            return .czar
        case 8...16:
            return .king;
        case 17...32:
            return .duke;
        case 33...64:
            return .earl;
        default:
            return .pawn;
        }
    }
}
