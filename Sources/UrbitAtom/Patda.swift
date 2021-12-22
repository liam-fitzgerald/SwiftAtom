//
//  File.swift
//  
//
//  Created by Liam Fitzgerald on 30/11/21.
//

import Foundation
import BigInt
import Parsing


func yawn(day: Int, month: Int, year: BigUInt) -> BigUInt {
    var days = BigUInt(integerLiteral: UInt64(day));
    days.decrement();
//    &(=(0 (mod yer 4)) |(!=(0 (mod yer 100)) =(0 (mod yer 400))))
    var i = year;
//    i -= 2;
    while (!i.isZero) {
        if((i % 4) != 0) {
            i.decrement();
            days += isLeapYear(i) ? 366 : 365;
        } else if (0 != (i % 100)) {
            i -= 4;
            days += isLeapYear(i) ? 1461 : 1460;
        } else if (0 != (i % 400)) {
            i -= 100;
            days += isLeapYear(i) ? 36525 : 36524;
        } else {
            let fst = BigUInt(integerLiteral: UInt64(i / 400));
                              
            let snd = BigUInt(integerLiteral: 1 + (4 * 36524));
            days += fst * snd;
            i = BigUInt("0");
        }
    }
    for j in 1..<month {
        days += BigUInt(daysPerMonth(j, leap: isLeapYear(year)));
    }
    return days;
}

func yall(days: BigUInt) -> (Int, Int, Int) {
    var daysSinceEpoch = days - EPOCH_DAYS;
    print(daysSinceEpoch);
    let eras = daysSinceEpoch / ERA_YO;
    daysSinceEpoch %= ERA_YO;
    var year = eras * 400;
    print(daysSinceEpoch);
    while((daysSinceEpoch / (isLeapYear(BigUInt(year)) ? 366 : 365)) != 0) {
        daysSinceEpoch -= isLeapYear(BigUInt(year)) ? 366 : 365;
        year += 1;
    }
    var month = 1;
    let isLeap = isLeapYear(year);
    while((daysSinceEpoch / daysPerMonth(month, leap: isLeap)) != BigUInt.zero) {
        daysSinceEpoch -= BigUInt(daysPerMonth(month, leap: isLeap));
        month += 1;
    }
        
        
    return (Int(year), month, Int(daysSinceEpoch) + 1);
}




fileprivate let DAY_YO = BigUInt("86400");
fileprivate let HOR_YO = BigUInt("3600");
fileprivate let MIT_YO = BigUInt("60");
fileprivate let ERA_YO = BigUInt("146097");
fileprivate let CET_YO = BigUInt("36524");
fileprivate let EPOCH = BigUInt("292277024400");
fileprivate let EPOCH_DAYS = BigUInt("106751991084417");
fileprivate let EPOCH_ERA =  EPOCH / ERA_YO;
fileprivate let EPOCH_CET = (EPOCH % ERA_YO) / CET_YO;
fileprivate let EPOCH_DAYS_FROM_ERA = BigUInt("15085976")

func yule(days: BigUInt, hours: Int, minutes: Int, seconds: Int, millis: [UInt8]) -> BigUInt {
    var seconds = BigUInt(integerLiteral: UInt64(seconds));
    seconds += BigUInt(integerLiteral: UInt64(minutes)) * MIT_YO;
    seconds += BigUInt(integerLiteral: UInt64(hours)) * HOR_YO;
    seconds += (days * BigUInt(integerLiteral: UInt64(DAY_YO)));
    
    return seconds;
}

private func isLeapYear(_ year: BigUInt) -> Bool {
    return (0 == (year % 4)) && ((0 != (year % 100)) || (0 == (year % 400)))
}

private func daysPerMonth(_ m: Int, leap: Bool) -> BigUInt {
         if(m == 2) {
             return BigUInt(leap ? 29 : 28);
        } else if(m == 4 || m == 6 || m == 9 || m == 11) {
            return BigUInt(30);
        } else {
            return BigUInt(31);
        }
   
}


struct Patda: Aura {
    var value: BigUInt;
    static let strParser = 0;
    init?(fromString: String) {
        self.value = BigUInt(integerLiteral: 0);
        let trelParser = Int.parser().skip(".").take(Int.parser()).skip(".").take(Int.parser());
        
        let millisParser = Prefix(...4)
            .pipe(UInt64.parser(of: Substring.self, isSigned: false, radix: 16));
        
        let dateParser = Skip("~").take(trelParser).skip("..").take(trelParser).take(Optional.parser(of: Skip("..").take(millisParser)))
        
        guard let parsed = dateParser.parse(fromString) else {
            return nil;
        }
        let (y,m,d, (h,mm,s), millis) = parsed;
        var mil = millis ?? 0;
        let days = yawn(day: d, month: m, year: BigUInt(UInt64(y)) + EPOCH);
        var seconds = yule(days: days, hours: h, minutes: mm, seconds: s, millis: []);
        seconds <<= 64;
        mil  <<= 48;
        seconds |= (BigUInt(integerLiteral: mil));
        value = seconds;
    }
    
    var scot: String {
        let (y,m,d) = yall(days: totalDays)
        let date = "\(y).\(m).\(d)";
        let time = String(format: "%02d.%02d.%02d", hours, minutes, seconds);
        var frac = "";
        if(millisEight.count != 0) {
            frac = ".";
            for byte in millisEight  {
               frac = String(format: "\(frac).%04x", byte);
            }
        }
        return "~\(date)..\(time)\(frac)";
    }
    
    var totalSeconds: BigUInt {
        return value >> 64;
    }
    var millis: UInt64 {
        return UInt64(value & BigUInt(UINT64_MAX))
    }
    var millisEight: [UInt16] {
        var result: [UInt16] = [];
        var mil = millis;
        print("Millis");
        print(String(format: "%lx", mil));
        var i = 1;
        let maskBits = UInt64(65535);
        while(i != 5 && mil != 0) {
            let bitOffset = 64 - (16*i);
            let mask: UInt64 = UInt64(maskBits << bitOffset);
            result.append(UInt16((mil & mask) >> bitOffset));
            mil &= ~mask;
            i += 1;
        }
        print("result: \(result)")
        return result;
    }
    
    var seconds: Int {
        let res = totalSeconds % 60;
        return Int(res);
    }
    
    var minutes: Int {
        let res = ((totalSeconds % HOR_YO) / MIT_YO);
        return Int(res);
    }
    var hours: Int {
        let res = ((totalSeconds % DAY_YO) / HOR_YO );
        return Int(res);
    }
    var totalDays: BigUInt {
      return (totalSeconds / DAY_YO);
    }
    
    var date: (Int, Int, Int) {
        return yall(days: totalDays);
    }
    var year: Int {
        let (y, _, _) = date;
        return y;
    }
    
}
//25 ++  yawn                                                ::  days since Jesus
//24   |=  [yer=@ud mot=@ud day=@ud]
//23   ^-  @ud
//22   =>  .(mot (dec mot), day (dec day))
//21   =>  ^+  .
//20       %=    .
//19           day
//18         =+  cah=?:((yelp yer) moy:yo moh:yo)
//17         |-  ^-  @ud
//16         ?:  =(0 mot)
//15           day
//14         $(mot (dec mot), cah (slag 1 cah), day (add day (snag 0 cah)))
//13       ==
//12   |-  ^-  @ud
//11   ?.  =(0 (mod yer 4))
//10     =+  ney=(dec yer)
// 9     $(yer ney, day (add day ?:((yelp ney) 366 365)))
// 8   ?.  =(0 (mod yer 100))
// 7     =+  nef=(sub yer 4)
// 6     $(yer nef, day (add day ?:((yelp nef) 1.461 1.460)))
// 5   ?.  =(0 (mod yer 400))
// 4     =+  nec=(sub yer 100)
// 3     $(yer nec, day (add day ?:((yelp nec) 36.525 36.524)))
// 2   (add day (mul (div yer 400) (add 1 (mul 4 36.524))))
