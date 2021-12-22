//
//  File.swift
//  
//
//  Created by Liam Fitzgerald on 1/12/21.
//

import Foundation
import Parsing
import BigInt

enum Pfix: String, CaseIterable {
        case doz, mar, bin, wan, sam, lit, sig, hid, fid, lis, sog, dir, wac, sab, wis, sib
        case rig, sol, dop, mod, fog, lid, hop, dar, dor, lor, hod, fol, rin, tog, sil, mir
        case hol, pas, lac, rov, liv, dal, sat, lib, tab, han, tic, pid, tor, bol, fos, dot
        case los, dil, `for`, pil, ram, tir, win, tad, bic, dif, roc, wid, bis, das, mid, lop
        case ril, nar, dap, mol, san, loc, nov, sit, nid, tip, sic, rop, wit, nat, pan, min
        case rit, pod, mot, tam, tol, sav, pos, nap, nop, som, fin, fon, ban, mor, wor, sip
        case ron, nor, bot, wic, soc, wat, dol, mag, pic, dav, bid, bal, tim, tas, mal, lig
        case siv, tag, pad, sal, div, dac, tan, sid, fab, tar, mon, ran, nis, wol, mis, pal
        case las, dis, map, rab, tob, rol, lat, lon, nod, nav, fig, nom, nib, pag, sop, ral
        case bil, had, doc, rid, moc, pac, rav, rip, fal, tod, til, tin, hap, mic, fan, pat
        case tac, lab, mog, sim, son, pin, lom, ric, tap, fir, has, bos, bat, poc, hac, tid
        case hav, sap, lin, dib, hos, dab, bit, bar, rac, par, lod, dos, bor, toc, hil, mac
        case tom, dig, fil, fas, mit, hob, har, mig, hin, rad, mas, hal, rag, lag, fad, top
        case mop, hab, `nil`, nos, mil, fop, fam, dat, nol, din, hat, nac, ris, fot, rib, hoc
        case nim, lar, fit, wal, rap, sar, nal, mos, lan, don, dan, lad, dov, riv, bac, pol
        case lap, tal, pit, nam, bon, ros, ton, fod, pon, sov, noc, sor, lav, mat, mip, fip
        
}

extension Pfix {
    public init(byte: UInt8) {
        self = Pfix.allCases[Int(byte)]
    }
    
    public var byte: UInt8 {
        return UInt8(Pfix.allCases.firstIndex(of: self)!)
    }
    
    static func parser() -> PfixParser {
        return PfixParser();
    }
    
}

public enum Sfix: String, CaseIterable {

    case zod, nec, bud, wes, sev, per, sut, `let`, ful, pen, syt, dur, wep, ser, wyl, sun
    case ryp, syx, dyr, nup, heb, peg, lup, dep, dys, put, lug, hec, ryt, tyv, syd, nex
    case lun, mep, lut, sep, pes, del, sul, ped, tem, led, tul, met, wen, byn, hex, feb
    case pyl, dul, het, mev, rut, tyl, wyd, tep, bes, dex, sef, wyc, bur, der, nep, pur
    case rys, reb, den, nut, sub, pet, rul, syn, reg, tyd, sup, sem, wyn, rec, meg, net
    case sec, mul, nym, tev, web, sum, mut, nyx, rex, teb, fus, hep, ben, mus, wyx, sym
    case sel, ruc, dec, wex, syr, wet, dyl, myn, mes, det, bet, bel, tux, tug, myr, pel
    case syp, ter, meb, set, dut, deg, tex, sur, fel, tud, nux, rux, ren, wyt, nub, med
    case lyt, dus, neb, rum, tyn, seg, lyx, pun, res, red, fun, rev, ref, mec, ted, rus
    case bex, leb, dux, ryn, num, pyx, ryg, ryx, fep, tyr, tus, tyc, leg, nem, fer, mer
    case ten, lus, nus, syl, tec, mex, pub, rym, tuc, fyl, lep, deb, ber, mug, hut, tun
    case byl, sud, pem, dev, lur, def, bus, bep, run, mel, pex, dyt, byt, typ, lev, myl
    case wed, duc, fur, fex, nul, luc, len, ner, lex, rup, ned, lec, ryd, lyd, fen, wel
    case nyd, hus, rel, rud, nes, hes, fet, des, ret, dun, ler, nyr, seb, hul, ryl, lud
    case rem, lys, fyn, wer, ryc, sug, nys, nyl, lyn, dyn, dem, lux, fed, sed, bec, mun
    case lyr, tes, mud, nyt, byr, sen, weg, fyr, mur, tel, rep, teg, pec, nel, nev, fes
    
}

extension Sfix {
    
    public init(byte: UInt8) {
        self = Sfix.allCases[Int(byte)]
    }
    
    public var byte: UInt8 {
        return UInt8(Sfix.allCases.firstIndex(of: self)!)
    }
    
    static func parser() -> SfixParser {
        return SfixParser();
    }
    
}

struct PfixParser: Parser
{
    public typealias Input = Substring;
    typealias Output = UInt8;
    
    @inlinable
    public func parse(_ input: inout Input) -> Output? {
        let syl = input.prefix(3);
        print(input);
        if(syl.count != 3) {
           return nil;
        }
        guard let byt = Pfix(rawValue: String(syl)) else {
            return nil;
        }
        input.removeFirst(3);
        return byt.byte;
    }
}

public struct SfixParser: Parser
{
    public typealias Input = Substring;
    public typealias Output = UInt8;
    
    @inlinable
    public func parse(_ input: inout Input) -> Output? {
        let syl = input.prefix(3);
        print(input);
        if(syl.count != 3) {
           return nil;
        }
        guard let byt = Sfix(rawValue: String(syl)) else {
            return nil;
        }
        input.removeFirst(3);
        return byt.byte
    }
}

fileprivate let galaxy = Sfix.parser().skip(End()).map({ BigUInt($0) })

fileprivate let starParse = Pfix.parser().take(Sfix.parser()).map({
    (one, two) -> BigUInt in
    var res = UInt64(one) << 8;
    res |= UInt64(two);
    return BigUInt(res);
});

fileprivate let star = starParse.skip(End());
fileprivate let planet = starParse.skip("-").take(starParse).skip(End()).map({
    (one, two) -> BigUInt in
    var acc = one;
    acc <<= 16
    acc |= BigUInt(two)
    return Ob.deobfuscate(acc);
})

public struct PointParser: Parser {
    public typealias Input = Substring;
    public typealias Output = BigUInt;
    
    public func parse(_ input: inout Input) -> Output? {
        return Skip("~").take(planet.orElse(star.orElse(galaxy))).parse(&input);
    }
}


