// Copyright (C) 2023 kaxori.
// Use of this source code is governed by an MIT-style license 
// that can be found in the LICENSE file.

/**
simple Driver for the ADS1115 

    - a 4 channel high-resolution analog to digital converter
    - the I2C bus is connected to pin 21 (SDA) and pin 22 (SCL)
    - the device address is 0x48 (or 0x49 by jumper).  
    - 4 channels single ended

    - see https://cdn-learn.adafruit.com/downloads/pdf/adafruit-4-channel-adc-breakouts.pdf for detailed info.
*/


import binary
import serial.device as serial
import serial.registers as serial


class ADS1115:
  registers_ /serial.Registers ::= ?

  constructor dev/serial.Device:
    registers_ = dev.registers

  readChannel channel/int -> int:
    if channel > 3: return 0
    return _readRaw channel 


  _readRaw channel/int=0 -> int:
    rate := 4
    _writeRegister _REGISTER_CONFIG \
      (_CQUE_NONE | _CLAT_NONLAT | \
      _CPOL_ACTVLOW | _CMODE_TRAD | _RATES_DR_3300SPS | \
      _MODE_SINGLE | _OS_SINGLE | 0x0200 | SINGLE_ENDED[channel] )
    
    while (_readRegister _REGISTER_CONFIG) & _OS_MASK == _OS_BUSY:
      sleep --ms=1

    raw := _readRegister _REGISTER_CONVERT
    return raw < 32768 ? raw : raw - 65536

  _readRegister register:
    reg := registers_.read_u16_be register
    return reg

  _writeRegister register value:
    registers_.write_u16_be register value
    
  static _REGISTER_MASK ::= (0x03)
  static _REGISTER_CONVERT ::= (0x00)
  static _REGISTER_CONFIG ::= (0x01)
  static _REGISTER_LOWTHRESH ::= (0x02)
  static _REGISTER_HITHRESH ::= (0x03)

  static _OS_MASK ::= (0x8000)
  static _OS_SINGLE ::= (0x8000)  // Write: Set to start a single-conversion
  static _OS_BUSY ::= (0x0000)  // Read: Bit=0 when conversion is in progress
  static _OS_NOTBUSY ::= (0x8000)  // Read: Bit=1 when no conversion is in progress

  static _MUX_MASK ::= (0x7000)
  static _MUX_DIFF_0_1 ::= (0x0000)  // Differential P  =  AIN0, N  =  AIN1 (default)
  static _MUX_DIFF_0_3 ::= (0x1000)  // Differential P  =  AIN0, N  =  AIN3
  static _MUX_DIFF_1_3 ::= (0x2000)  // Differential P  =  AIN1, N  =  AIN3
  static _MUX_DIFF_2_3 ::= (0x3000)  // Differential P  =  AIN2, N  =  AIN3

  static _MUX_SINGLE_0 ::= (0x4000)  // Single-ended AIN0
  static _MUX_SINGLE_1 ::= (0x5000)  // Single-ended AIN1
  static _MUX_SINGLE_2 ::= (0x6000)  // Single-ended AIN2
  static _MUX_SINGLE_3 ::= (0x7000)  // Single-ended AIN3

  static SINGLE_ENDED ::= [ _MUX_SINGLE_0, _MUX_SINGLE_1, _MUX_SINGLE_2, _MUX_SINGLE_3 ]


  static _PGA_MASK ::= (0x0E00)
  static _PGA_6_144V ::= (0x0000)  // +/-6.144V range  =  Gain 2/3
  static _PGA_4_096V ::= (0x0200)  // +/-4.096V range  =  Gain 1
  static _PGA_2_048V ::= (0x0400)  // +/-2.048V range  =  Gain 2 (default)
  static _PGA_1_024V ::= (0x0600)  // +/-1.024V range  =  Gain 4
  static _PGA_0_512V ::= (0x0800)  // +/-0.512V range  =  Gain 8
  static _PGA_0_256V ::= (0x0A00)  // +/-0.256V range  =  Gain 16

  static _MODE_MASK ::= (0x0100)
  static _MODE_CONTIN ::= (0x0000)  // Continuous conversion mode
  static _MODE_SINGLE ::= (0x0100)  // Power-down single-shot mode (default)

  static _DR_MASK ::= (0x00E0)     // Values ADS1015/ADS1115
  static _DR_128SPS ::= (0x0000)   // 128 /8 samples per second
  static _DR_250SPS ::= (0x0020)   // 250 /16 samples per second
  static _DR_490SPS ::= (0x0040)   // 490 /32 samples per second
  static _DR_920SPS ::= (0x0060)   // 920 /64 samples per second
  static _DR_1600SPS ::= (0x0080)  // 1600/128 samples per second (default)
  static _DR_2400SPS ::= (0x00A0)  // 2400/250 samples per second
  static _DR_3300SPS ::= (0x00C0)  // 3300/475 samples per second
  static _DR_860SPS ::= (0x00E0)  // -   /860 samples per Second

  static _CMODE_MASK ::= (0x0010)
  static _CMODE_TRAD ::= (0x0000)  // Traditional comparator with hysteresis (default)
  static _CMODE_WINDOW ::= (0x0010)  // Window comparator

  static _CPOL_MASK ::= (0x0008)
  static _CPOL_ACTVLOW ::= (0x0000)  // ALERT/RDY pin is low when active (default)
  static _CPOL_ACTVHI ::= (0x0008)  // ALERT/RDY pin is high when active

  static _CLAT_MASK ::= (0x0004)  // Determines if ALERT/RDY pin latches once asserted
  static _CLAT_NONLAT ::= (0x0000)  // Non-latching comparator (default)
  static _CLAT_LATCH ::= (0x0004)  // Latching comparator

  static _CQUE_MASK ::= (0x0003)
  static _CQUE_1CONV ::= (0x0000)  // Assert ALERT/RDY after one conversions
  static _CQUE_2CONV ::= (0x0001)  // Assert ALERT/RDY after two conversions
  static _CQUE_4CONV ::= (0x0002)  // Assert ALERT/RDY after four conversions
    // Disable the comparator and put ALERT/RDY in high state (default)
  static _CQUE_NONE ::= (0x0003)


  static _GAINS_PGA_6_144V ::= 0
  static _GAINS_PGA_4_096V ::= 1  // 1x
  static _GAINS_PGA_2_048V ::= 2  // 2x
  static _GAINS_PGA_1_024V ::= 3  // 4x
  static _GAINS_PGA_0_512V ::= 4  // 8x
  static _GAINS_PGA_0_256V ::= 5   // 16x


  static _RATES_DR_128SPS ::= 0 // 128/8 samples per second
  static _RATES_DR_250SPS ::= 1 // 250/16 samples per second
  static _RATES_DR_490SPS ::= 2 // 490/32 samples per second
  static _RATES_DR_920SPS ::= 3 // 920/64 samples per second
  static _RATES_DR_1600SPS ::= 4 // 1600/128 samples per second (default)
  static _RATES_DR_2400SPS ::= 5 // 2400/250 samples per second
  static _RATES_DR_3300SPS ::= 6 // 3300/475 samples per second
  static _RATES_DR_860SPS ::= 7 // - /860 samples per Second


  static _GAINS_TWOTHIRDS  ::=  6.144
  static _GAINS_1X  ::=  4.096
  static _GAINS_2X  ::=  2.048
  static _GAINS_4X  ::=  1.024
  static _GAINS_8X  ::=  0.512
  static _GAINS_16X  ::=  0.256

  static _CHANNELS_MUX_SINGLE_0 ::= [0, 0]
  static _CHANNELS_MUX_SINGLE_1 ::= [1, 0] 
  static _CHANNELS_MUX_SINGLE_2 ::= [2, 0]   
  static _CHANNELS_MUX_SINGLE_3 ::= [3, 0] 
  static _CHANNELS_MUX_DIFF_0_1 ::= [0, 1 ]   
  static _CHANNELS_MUX_DIFF_0_3 ::= [0, 3 ] 
  static _CHANNELS_MUX_DIFF_1_3 ::= [1, 3 ]   
  static _CHANNELS_MUX_DIFF_2_3 ::= [2, 3 ] 