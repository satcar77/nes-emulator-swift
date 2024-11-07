import Foundation

struct CpuFlags: OptionSet {
    var rawValue: UInt8

    static let carry             = CpuFlags(rawValue: 1 << 0)
    static let zero              = CpuFlags(rawValue: 1 << 1)
    static let interruptDisable  = CpuFlags(rawValue: 1 << 2)
    static let decimalMode       = CpuFlags(rawValue: 1 << 3)
    static let brk           = CpuFlags(rawValue: 1 << 4)
    static let brk2            = CpuFlags(rawValue: 1 << 5)
    static let overflow          = CpuFlags(rawValue: 1 << 6)
    static let negative          = CpuFlags(rawValue: 1 << 7)
}

let STACK : UInt16 = 0x0100;
let STACK_RESET: UInt8 = 0xfd;




public class CPU {
    public var register_a : UInt8;
    public var register_x : UInt8;
    public var register_y : UInt8;
    var status : CpuFlags;
    public var pc : UInt16;
    public var sp : UInt8;
    public var bus : Bus;
    private var opc_map = getOpcodesMap();
    var callback: ()->Void;
    
    public init(bi_bus : Bus){
        register_a = 0;
        status = [] ;
        pc = 0;
        bus = bi_bus;
        register_x = 0;
        register_y = 0;
        sp = STACK_RESET;
        callback = {};
    }
    
    public func get_status() -> UInt8{
        return self.status.rawValue
    }
    
    func mem_read(addr: UInt16) -> UInt8{
        return self.bus.mem_read(addr :addr);
    }
    
    func mem_write(addr:UInt16,data :UInt8) {
        self.bus.mem_write(addr: addr, data: data);
    }
    
    func mem_read_16(addr:UInt16) -> UInt16 {
        let low = UInt16(self.mem_read(addr: addr))
        let high = UInt16(self.mem_read(addr: addr + 1))
        return high << 8 | low;
    }
    
    func mem_write_u16(addr:UInt16,data:UInt16){
        let high = UInt8(data >> 8);
        let low = UInt8(data & 0xff);
        self.mem_write(addr: addr, data: low);
        self.mem_write(addr: addr + 1, data: high);
    }
    
    func check_page_cross(addr1 : UInt16 , addr2 : UInt16)-> Bool{
        return addr1 & 0xFF00 !=  addr2 & 0xFF00;
    }
    
    public func get_abs_addr(mode: AddressingMode, addr : UInt16?=nil) -> (UInt16,Bool) {
        let address = addr ?? self.pc
        switch mode{
        case AddressingMode.Immediate : return (address,false);
        case AddressingMode.ZeroPage : return (UInt16(self.mem_read(addr: address)),false);
        case AddressingMode.Absolute : return (self.mem_read_16(addr: address),false);
        case AddressingMode.ZeroPage_X :
            let val = self.mem_read(addr: address);
            return (UInt16(val &+ self.register_x),false);
        case AddressingMode.ZeroPage_Y :
            let val = self.mem_read(addr: address);
            return (UInt16(val &+ self.register_y),false);
        case AddressingMode.Absolute_X:
            let val = self.mem_read_16(addr: address);
            let res = val &+ UInt16(self.register_x)
            return (res, check_page_cross(addr1: val, addr2: res));
        case AddressingMode.Absolute_Y:
            let val = self.mem_read_16(addr: address);
            let res = val &+ UInt16(self.register_y);
            return (res, check_page_cross(addr1: val, addr2: res));
        case AddressingMode.Indirect_X:
            let val = self.mem_read(addr: address);
            let ptr = val &+ self.register_x;
            let low = self.mem_read(addr: UInt16(ptr));
            let high = self.mem_read(addr: UInt16(ptr &+ 1));
            return (UInt16(high) << 8 | UInt16(low),false);
        case AddressingMode.Indirect_Y:
            let val = self.mem_read(addr: address);
            let low = self.mem_read(addr: UInt16(val));
            let high = self.mem_read(addr: UInt16(val &+ 1));
            let reref = UInt16(high) << 8 | UInt16(low);
            let res = reref &+ UInt16(self.register_y)
            return (res,check_page_cross(addr1: reref, addr2: res));
        default :
            fatalError("Unrecgnized addressing mode \(mode)");
        }
    }
    
    func update_zn_flags(value: UInt8){
        if value == 0 {
            self.status.insert(CpuFlags.zero)
        }else{
            self.status.remove(CpuFlags.zero)
        }
        if value & 0b1000_0000 != 0 {
            self.status.insert(CpuFlags.negative);
        }else{
            self.status.remove(CpuFlags.negative);
        }
    }
    
    
    func ldy(mode:AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let data = self.mem_read(addr: addr);
        self.register_y = data;
        self.update_zn_flags(value: self.register_y);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func ldx(mode:AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let data = self.mem_read(addr: addr);
        self.register_x = data;
        self.update_zn_flags(value: self.register_x);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func lda(mode:AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let data = self.mem_read(addr: addr);
        self.register_a = data;
        self.update_zn_flags(value: register_a);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func sta(mode:AddressingMode){
        let (addr,_) = self.get_abs_addr(mode: mode);
        self.mem_write(addr: addr, data: self.register_a)
    }
    
    func and(mode :AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let data = self.mem_read(addr: addr);
        self.register_a = data & self.register_a;
        self.update_zn_flags(value: self.register_a);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func eor(mode :AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let data = self.mem_read(addr: addr);
        self.update_acc(val: data ^ self.register_a);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func ora(mode : AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let val = self.mem_read(addr: addr);
        self.register_a = val | self.register_a;
        update_zn_flags(value: self.register_a);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func tax(){
        self.register_x = self.register_a;
        self.update_zn_flags(value: self.register_x);
    }
    
    func inx() {
        self.register_x = self.register_x &+ 1;
        self.update_zn_flags(value: self.register_x)
    }
    
    func iny() {
        self.register_y = self.register_y &+ 1;
        self.update_zn_flags(value: self.register_y)
    }
    
    func load(program:[UInt8]){
        for i in 0...program.count {
            self.mem_write(addr: 0x8600 + UInt16(i), data: program[i]);
        }
        self.mem_write_u16(addr: 0xFFFC, data: 0x8600);
        self.reset();
    }
    
    func load_run(program:[UInt8]){
        self.load(program: program);
        self.run();
    }
    
    func run_with_callback(callback:@escaping ()->Void){
        self.callback = callback;
        self.run();
    }
    
    
    public func reset(){
        self.register_a = 0;
        self.register_x = 0;
        self.register_y = 0;
        self.status.rawValue = 0b100100;
        self.pc = self.mem_read_16(addr: 0xFFFC);
        self.sp = STACK_RESET;
    }
    
    func add_to_acc(data:UInt8){
        let sum = UInt16(self.register_a) + UInt16(data) + (self.status.contains(CpuFlags.carry) ? UInt16(1) : UInt16(0));
        let carry = sum > 0xff;
        if carry {
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        let res = UInt8(sum & 0x00FF);
        if (data ^ res) & (res ^ self.register_a) & 0x80 != 0 {
            self.status.insert(CpuFlags.overflow);
        }else{
            self.status.remove(CpuFlags.overflow);
        }
        self.update_zn_flags(value: res)
        self.register_a = res;
    }
    
    
    func sbc(mode:AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let val = self.mem_read(addr: addr);
        self.add_to_acc(data: ~val)
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func adc(mode:AddressingMode){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let val = self.mem_read(addr: addr);
        self.add_to_acc(data: val)
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func stack_pop() -> UInt8 {
        self.sp = self.sp &+ 1;
        return self.mem_read(addr: (STACK) + UInt16(self.sp));
    }
    
    func stack_push(data : UInt8){
        self.mem_write(addr: STACK + UInt16(self.sp), data: data);
        self.sp = self.sp &- 1;
    }
    
    func stack_push_u16(data: UInt16){
        let high = UInt8(data >> 8);
        let low = UInt8(data & 0xFF);
        self.stack_push(data: high);
        self.stack_push(data: low);
    }
    
    func stack_pop_u16() -> UInt16{
        let low = UInt16(self.stack_pop());
        let high = UInt16(self.stack_pop());
        return high << 8 | low
    }
    
    func update_acc(val : uint8){
        self.register_a = val ;
        self.update_zn_flags(value: val)
    }
    
    func update_neg_flags(val:UInt8){
        if val >> 7 == 1{
            self.status.insert(CpuFlags.negative);
        }else{
            self.status.remove(CpuFlags.negative);
        }
    }
    
    
    func asl_acc(){
        var val = self.register_a;
        if val >> 7 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val = val << 1;
        self.update_acc(val: val);
    }
    
    func asl(mode:AddressingMode) -> UInt8 {
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        if val >> 7 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val = val << 1;
        self.mem_write(addr: addr, data: val);
        self.update_zn_flags(value: val);
        return val;
    }
    
    func lsr_acc(){
        var val = self.register_a;
        if val & 1 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val = val >> 1;
        self.update_acc(val: val);
    }
    
    func lsr(mode:AddressingMode) -> UInt8 {
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        if val & 1 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val = val >> 1;
        self.mem_write(addr: addr, data: val);
        self.update_zn_flags(value: val);
        return val;
    }
    
    
    func rol(mode: AddressingMode) -> UInt8{
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        let cari = self.status.contains(CpuFlags.carry);
        
        if val >> 7 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val =  val << 1;
        if cari {
            val = val | 1;
        }
        self.mem_write(addr: addr, data: val);
        self.update_neg_flags(val: val);
        return val;
    }
    
    func rol_acc(){
        var val = self.register_a;
        let cari = self.status.contains(CpuFlags.carry);
        
        if val >> 7 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val =  val << 1;
        if cari {
            val = val | 1;
        }
        update_acc(val: val);
    }
    
    func ror(mode: AddressingMode) -> UInt8{
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        let cari = self.status.contains(CpuFlags.carry);
        
        if val & 1 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val =  val >> 1;
        if cari {
            val = val | 0b10000000;
        }
        self.mem_write(addr: addr, data: val);
        self.update_neg_flags(val: val);
        return val;
    }
    
    func ror_acc(){
        var val = self.register_a;
        let cari = self.status.contains(CpuFlags.carry);
        
        if val & 1 == 1{
            self.status.insert(CpuFlags.carry);
        }else{
            self.status.remove(CpuFlags.carry);
        }
        val =  val >> 1;
        if cari {
            val = val |  0b10000000;
        }
        update_acc(val: val);
    }
    
    func inc(mode:AddressingMode) -> UInt8 {
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        val = val &+ 1;
        self.mem_write(addr: addr, data: val);
        self.update_zn_flags(value: val);
        return val
    }
    
    func dec(mode:AddressingMode) -> UInt8 {
        let (addr,_) = self.get_abs_addr(mode: mode);
        var val = self.mem_read(addr: addr);
        val = val &- 1;
        self.mem_write(addr: addr, data: val);
        self.update_zn_flags(value: val);
        return val
    }
    
    func dey(){
        self.register_y = self.register_y &- 1;
        self.update_zn_flags(value: self.register_y);
    }
    
    func dex(){
        self.register_x = self.register_x &- 1;
        self.update_zn_flags(value: self.register_x);
    }
    
    func pla(){
        let val = self.stack_pop();
        self.register_a = val ;
        update_zn_flags(value: val);
    }
    
    func plp(){
        self.status.rawValue = self.stack_pop();
        self.status.remove(CpuFlags.brk);
        self.status.insert(CpuFlags.brk2);
    }
    
    func php(){
        var flags = self.status.rawValue;
        var newFlags = CpuFlags(rawValue: flags);
        newFlags.insert(.brk);
        newFlags.insert(.brk2);
        self.stack_push(data: newFlags.rawValue);
    }
    
    func bit(mode:AddressingMode){
        let (addr,_) = self.get_abs_addr(mode: mode);
        let val = self.mem_read(addr: addr);
        let and = self.register_a & val;
        if and == 0 {
            self.status.insert(.zero);
        }else{
            self.status.remove(.zero);
        }
        if (val & 0b10000000 > 0){
            self.status.insert(.negative);
        }else{
            self.status.remove(.negative);
        }
        
        if (val & 0b01000000 > 0){
            self.status.insert(.overflow);
        }else{
            self.status.remove(.overflow);
        }
    }
    
    func compare(mode :AddressingMode,with: UInt8){
        let (addr,cross) = self.get_abs_addr(mode: mode);
        let val = self.mem_read(addr: addr);
        if val <= with {
            self.status.insert(.carry);
        }else{
            self.status.remove(.carry);
        }
        self.update_zn_flags(value: with &- val);
        if cross {
            self.bus.tick(cycles: 1);
        }
    }
    
    func branch(cond : Bool){
        if cond {
            let jmp = Int8(bitPattern: self.mem_read(addr: self.pc));
            let jmp_addr = self.pc &+ 1 &+ UInt16(bitPattern: Int16(jmp));
            self.pc = jmp_addr;
        }
    }
    
    func nmi_interrupt(){
        self.stack_push_u16(data: self.pc);
        var flag = CpuFlags(rawValue: self.status.rawValue);
        flag.remove(.brk);
        flag.insert(.brk2);
        self.stack_push(data: flag.rawValue);
        self.status.insert(.interruptDisable);
        self.bus.tick(cycles: 2);
        self.pc = self.mem_read_16(addr: 0xfffA);
        
    }
    
    
    public func step(){
        while true {
            if self.bus.poll_nmi() == 1 {
                self.nmi_interrupt();
            }
            let opcode = self.mem_read(addr: self.pc);
            guard let op_inf = opc_map[opcode] else {
                fatalError("Error: Opcode \(opcode) not implemented.")
            }
            self.pc += 1
            let pc_check = self.pc
            switch opcode {
            case 0xa9,0xa5,0xb5,0xad,0xbd,0xb9,0xa1,0xb1 :
                self.lda(mode: op_inf.mode);
            case 0xAA :
                self.tax();
            case 0xe8:
                self.inx();
            case 0x00:
                return;
            case 0xd8:
                self.status.remove(.decimalMode);
            case 0x58:
                self.status.remove(.interruptDisable);
            case 0xb8:
                self.status.remove(.overflow);
            case 0x18:
                self.status.remove(.carry);
            case 0x38:
                self.status.insert(.carry);
            case 0x78:
                self.status.insert(.interruptDisable);
            case 0xf8:
                self.status.insert(.decimalMode);
            case 0x48:
                self.stack_push(data: self.register_a);
            case 0x68:
                self.pla();
            case 0x08:
                self.php();
            case 0x28:
                self.plp();
            case 0x69, 0x65,0x75,0x6d,0x7d,0x79,0x61,0x71:
                self.adc(mode: op_inf.mode);
            case 0xe9, 0xe5,0xf5,0xed,0xfd,0xf9,0xe1,0xf1:
                self.sbc(mode: op_inf.mode);
            case 0x29,0x25,0x35,0x2d,0x3d,0x39,0x21,0x31:
                self.and(mode: op_inf.mode);
            case 0x49,0x45,0x55,0x4d,0x5d,0x59,0x41,0x51:
                self.eor(mode: op_inf.mode);
            case 0x09,0x05,0x15,0x0d,0x1d,0x19,0x01,0x11:
                
                self.ora(mode: op_inf.mode);
            case 0x4a:
                self.lsr_acc();
            case 0x46,0x56,0x4e,0x5e:
                self.lsr(mode: op_inf.mode);
            case 0x0a:
                self.asl_acc();
            case 0x06,0x16,0x0e,0x1e:
                self.asl(mode: op_inf.mode);
            case 0x2a:
                self.rol_acc();
            case 0x26,0x36,0x2e,0x3e:
                self.rol(mode: op_inf.mode);
            case 0x6a:
                self.ror_acc();
            case 0x66,0x76,0x6e,0x7e:
                self.ror(mode: op_inf.mode);
            case 0xe6,0xf6,0xee,0xfe:
                self.inc(mode: op_inf.mode);
            case 0xc8:
                self.iny();
            case 0xc6,0xd6,0xce,0xde:
                self.dec(mode: op_inf.mode);
            case 0xca:
                self.dex();
            case 0x88:
                self.dey();
            case 0xc9,0xc5,0xd5,0xcd,0xdd,0xd9,0xc1,0xd1:
                self.compare(mode: op_inf.mode,with: self.register_a);
            case 0xc0,0xc4,0xcc:
                self.compare(mode:op_inf.mode,with: self.register_y);
            case 0xe0,0xe4,0xec:
                self.compare(mode:op_inf.mode,with: self.register_x);
            case 0x4c:
                let addr = self.mem_read_16(addr: self.pc);
                self.pc = addr;
            case 0x6c:
                let addr = self.mem_read_16(addr: self.pc);
                let indirectRef: UInt16
                if addr & 0x00FF == 0x00FF {
                    let lo = self.mem_read(addr: addr);
                    let hi = self.mem_read(addr: addr & 0xFF00);
                    indirectRef = (UInt16(hi) << 8) | UInt16(lo);
                } else {
                    indirectRef = self.mem_read_16(addr: addr);
                }
                self.pc = indirectRef;
            case 0x20:
                self.stack_push_u16(data: self.pc + 1);
                let target = self.mem_read_16(addr: self.pc);
                self.pc = target;
            case 0x60 :
                self.pc = self.stack_pop_u16() + 1;
            case 0x40:
                self.status.rawValue = self.stack_pop();
                self.status.remove(.brk);
                self.status.insert(.brk2);
                self.pc = self.stack_pop_u16();
            case 0xd0:
                self.branch(cond: !self.status.contains(.zero));
            case 0x70:
                self.branch(cond: self.status.contains(.overflow));
            case 0x50:
                self.branch(cond: !self.status.contains(.overflow));
            case 0x10:
                self.branch(cond: !self.status.contains(.negative));
            case 0x30:
                self.branch(cond: self.status.contains(.negative));
            case 0xf0:
                self.branch(cond: self.status.contains(.zero));
            case 0xb0:
                self.branch(cond: self.status.contains(.carry));
            case 0x90:
                self.branch(cond: !self.status.contains(.carry));
            case 0x24, 0x2c :
                self.bit(mode: op_inf.mode);
            case 0x85,0x95,0x8d,0x9d,0x99,0x81,0x91:
                self.sta(mode: op_inf.mode);
            case 0x86,0x96,0x8e:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                self.mem_write(addr: addr, data: self.register_x);
            case 0x84,0x94,0x8c:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                self.mem_write(addr: addr, data: self.register_y);
            case 0xa2,0xa6,0xb6,0xae,0xbe:
                self.ldx(mode: op_inf.mode);
            case 0xa0,0xa4,0xb4,0xac,0xbc:
                self.ldy(mode: op_inf.mode);
            case 0xea:
                break;
            case 0xa8:
                self.register_y = self.register_a;
                self.update_zn_flags(value: self.register_y);
            case 0xba:
                self.register_x = self.sp;
                self.update_zn_flags(value: self.register_x);
            case 0x8a:
                self.register_a = self.register_x;
                self.update_zn_flags(value: self.register_a);
            case 0x9a:
                self.sp = self.register_x;
            case 0x98:
                self.register_a = self.register_y;
                self.update_zn_flags(value: self.register_a);
            case 0xc7,0xd7,0xcf,0xdf,0xdb,0xc3,0xd3:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                var data = self.mem_read(addr: addr);
                data = data &- 1;
                self.mem_write(addr: addr, data: data);
                if data <= self.register_a {
                    self.status.insert(.carry);
                }
                self.update_zn_flags(value: self.register_a &- data);
            case 0x27,0x37,0x2f,0x3f,0x3b,0x23,0x33:
                let data = self.rol(mode: op_inf.mode);
                self.register_a = data & self.register_a;
                self.update_zn_flags(value: self.register_a);
            case 0x07,0x17,0x0f,0x1f,0x1b,0x03,0x13:
                let data = self.asl(mode: op_inf.mode);
                self.register_a = data | self.register_a;
                self.update_zn_flags(value: self.register_a);
            case 0x47,0x57,0x4f,0x5f,0x5b,0x43,0x53:
                let data = self.lsr(mode: op_inf.mode);
                self.register_a = data ^ self.register_a;
                self.update_zn_flags(value: self.register_a);
            case 0x80, 0x82, 0x89, 0xc2, 0xe2:
                break;
            case 0xCB:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                var data = self.mem_read(addr: addr);
                let x_a = self.register_x & self.register_a;
                let res = x_a &- data;
                if data <= x_a {
                    self.status.insert(.carry);
                }
                self.update_zn_flags(value: res);
                self.register_x = res;
            case 0x6B:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                var data = self.mem_read(addr: addr);
                self.register_a = data ^ self.register_a;
                self.ror_acc();
                let res = self.register_a;
                let bit_5 = (data >> 5) & 1;
                let bit_6 = (data >> 6) & 1;
                if bit_6 == 1 {
                    self.status.insert(.carry);
                } else {
                    self.status.remove(.carry);
                }
                if bit_5 ^ bit_6 == 1 {
                    self.status.insert(.overflow);
                } else {
                    self.status.remove(.overflow);
                }
                
            case 0xeb:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                let data = self.mem_read(addr: addr);
                add_to_acc(data: ~data);
            case 0x0b | 0x2b:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                var data = self.mem_read(addr: addr);
                self.register_a = data & self.register_a;
                self.update_zn_flags(value: self.register_a);
                if self.status.contains(.negative){
                    self.status.insert(.carry);
                }
                else{
                    self.status.remove(.carry);
                }
            case 0x4b:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                var data = self.mem_read(addr: addr);
                self.register_a = data ^ self.register_a;
                self.update_zn_flags(value: self.register_a);
                self.lsr_acc();
                
            case 0x04,0x44,0x64,0x14,0x34,0x54,0x74,0xd4,0xf4,0x0c,0x1c:
                let (addr,cross) = self.get_abs_addr(mode: op_inf.mode);
                let data = self.mem_read(addr: addr);
                if cross {
                    self.bus.tick(cycles: 1);
                }
            case 0x67,0x77,0x6f,0x7f,0x7b,0x63,0x73:
                let data = self.ror(mode: op_inf.mode);
                self.add_to_acc(data: data);
            case 0xe7,0xf7,0xef,0xff,0xfb,0xe3,0xf3:
                let data = self.inc(mode: op_inf.mode);
                self.add_to_acc(data: ~data);
            case 0x02,0x12,0x22,0x32,0x42,0x52,0x62,0x72,0x92,0xb2,0xd2,0xf2,0x1a,0x3a,0x5a,0x7a,0xda,0xfa:
                continue;
            case 0xa7,0xb7,0xaf,0xbf,0xa3,0xb3:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                let data = self.mem_read(addr: addr);
                self.register_a = data;
                self.update_zn_flags(value: data);
                self.register_x = self.register_a;
            case 0x87,0x97,0x8f,0x83:
                let data = self.register_a & self.register_x;
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                self.mem_write(addr: addr, data: data);
            case 0xab:
                self.lda(mode: op_inf.mode);
                self.tax();
            case 0x8b:
                self.register_a = self.register_x;
                self.update_zn_flags(value: self.register_a);
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                let data = self.mem_read(addr: addr);
                self.register_a = data & self.register_a;
                self.update_zn_flags(value: self.register_a);
            case 0xbb:
                let (addr,_) = self.get_abs_addr(mode: op_inf.mode);
                let data = self.mem_read(addr: addr);
                self.register_a = data;
                self.register_x = data;
                self.sp = data;
                self.update_zn_flags(value: self.register_a);
            case 0x9b:
                let data = self.register_a & self.register_x;
                self.sp = data;
                let mem_addr = self.mem_read_16(addr: self.pc + UInt16(self.register_y));
                let data2 = (UInt8(mem_addr >> 8) + 1) & self.sp;
                self.mem_write(addr: mem_addr, data: data2);
                
            case 0x93:
                let addr = self.mem_read(addr: self.pc);
                let mem_addr = self.mem_read_16(addr: UInt16(addr)) + UInt16(self.register_y);
                let data = self.register_a & self.register_x & UInt8(mem_addr >> 8);
                self.mem_write(addr: mem_addr, data: data)
            case 0x9f:
                let mem_addr = self.mem_read_16(addr: self.pc) + UInt16(self.register_y);
                let data = self.register_a & self.register_x & UInt8(mem_addr >> 8);
                self.mem_write(addr: mem_addr, data: data);
            case 0x9e:
                let mem_addr = self.mem_read_16(addr: self.pc) + UInt16(self.register_y);
                let data = self.register_x & (UInt8(mem_addr >> 8) + 1 );
                self.mem_write(addr: mem_addr, data: data);
            case 0x9c:
                let mem_addr = self.mem_read_16(addr: self.pc) + UInt16(self.register_x);
                let data = self.register_y & (UInt8(mem_addr >> 8) + 1 );
                self.mem_write(addr: mem_addr, data: data);
                
            default:
                print("Invalid opcode: " + String(format: "%02X",opcode))
            }
            self.bus.tick(cycles : op_inf.cycles);
            if self.pc == pc_check {
                self.pc += UInt16(op_inf.len - 1);
            }
            break;
        }
    }
    
    public func run(){
        while true {
            self.step()
        }
    }
}
