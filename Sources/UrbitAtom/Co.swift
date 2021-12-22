//
//  Co.swift
//  
//
//  Created by Liam Fitzgerald on 1/12/21.
//

import Foundation
import MurmurHash_Swift
struct Ob {

    public static func obfuscate<T: UnsignedInteger>(_ value: T) -> T {
        switch value.bitWidth {
        case 17...32:
            let p32 = UInt32(value)
            return 0x10000 + T(feistelCipher(p32 - 0x10000))
        case 33...64:
            let low = value & 0x00000000FFFFFFFF
            let high = value & 0xFFFFFFFF00000000
            return high | obfuscate(low)
        default:
            return value
        }
    }

    public static func deobfuscate<T: UnsignedInteger>(_ value: T) -> T {
        switch value.bitWidth {
        case 17...32:
            let p32 = UInt32(value)
            return 0x10000 + T(reverseFeistelCipher(p32 - 0x10000))
        case 33...64:
            let low = value & 0x00000000FFFFFFFF
            let high = value & 0xFFFFFFFF00000000
            return high | deobfuscate(low)
        default:
            return value
        }
    }
    
}

extension Ob {

    public static func feistelCipher(_ m: UInt32) -> UInt32 {
        return capFe(4, 0xFFFF, 0x10000, 0xFFFFFFFF, capF, m)
    }
    
    public static func reverseFeistelCipher(_ m: UInt32) -> UInt32 {
        return capFen(4, 0xFFFF, 0x10000, 0xFFFFFFFF, capF, m)
    }
    
}

extension Ob {
    
    private static func muk(_ seed: UInt32, _ key: UInt32) -> UInt32 {
        let low = UInt8(key & 0x00FF)
        let high = UInt8(key & 0xFF00 / 0x0100)
        return MurmurHash3.x86_32.digest([low, high], seed: seed)
    }
    
}

extension Ob {
    
    private static func capF(_ j: Int, _ r: UInt32) -> UInt32 {
        let seeds: [UInt32] = [0xb76d5eed, 0xee281300, 0x85bcae01, 0x4b387af7]
        return muk(seeds[j], r)
    }
    
}

extension Ob {
    
    private static func capFe(_ r: Int, _ a: UInt32, _ b: UInt32, _ k: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        let c = fe(r, a, b, f, m)
        return c < k ? c : fe(r, a, b, f, c)
    }
    
    private static func fe(_ r: Int, _ a: UInt32, _ b: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        func loop(_ j: Int, _ ell: UInt32, _ arr: UInt32) -> UInt32 {
            if j > r {
                let isOdd = r % 2 == 1;
                if isOdd || arr == a {
                    return a * arr + ell
                } else {
                    return a * ell + arr
                }
            } else {
                let eff: UInt32 = f(j - 1, arr)
                let tmp: UInt32 = {
                    let isOdd = j % 2 == 1;
                    if(isOdd) {
                       return (ell % a + eff % a) % a
                        
                    } else {
                        return (ell % b + eff % b) % b
                    }
                }()
                
                return loop(j + 1, arr, tmp)
            }
        }
        
        let capL = m % a
        let capR = m / a
        
        return loop(1, capL, capR)
    }
    
}

extension Ob {
    
    private static func capFen(_ r: Int, _ a: UInt32, _ b: UInt32, _ k: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        let c = fen(r, a, b, f, m)
        return c <= k ? c : fen(r, a, b, f, c)
    }

    private static func fen(_ r: Int, _ a: UInt32, _ b: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        func loop(_ j: Int, ell: UInt32, arr: UInt32) -> UInt32 {
            if j < 1 {
                return a * arr + ell
            } else {
                let eff: UInt32 = f(j - 1, ell)
                let isOdd = j % 2 == 1;
                let tmp: UInt32 = {
                    if(isOdd) {
                        return (arr + a - (eff % a)) % a
                    } else {
                        return (arr + b - (eff % b)) % b
                    }
                }()
                return loop(j - 1, ell: tmp, arr: ell)
            }
        }
        
        let isOdd = r % 2 == 1;
        let ahh = isOdd ? m / a : m % a
        let ale = isOdd ? m % a : m / a
        let capL = ale == a ? ahh : ale
        let capR = ale == a ? ale : ahh
        
        return loop(r, ell: capL, arr: capR)
    }
    
}
