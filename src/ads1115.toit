// Copyright (C) 2023 kaxori.
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

/**
Driver for the ADS1115.

The ADS1115 is a 4 channel high-resolution analog to digital converter.
*/


import binary
import serial.device as serial
import serial.registers as serial

class Ads1115:
  static I2C_ADDRESS ::= 0x48
  static I2C_ADDRESS_ALT ::= 0x49

  static REGISTER_MASK_ ::= 0x03
  static REGISTER_CONVERT_ ::= 0x00
  static REGISTER_CONFIG_ ::= 0x01
  static REGISTER_LOWTHRESH_ ::= 0x02
  static REGISTER_HITHRESH_ ::= 0x03

  static OS_MASK_ ::= 0x8000
  static OS_SINGLE_ ::= 0x8000  // Write: Set to start a single-conversion.
  static OS_BUSY_ ::= 0x0000    // Read: Bit=0 when conversion is in progress.
  static OS_NOTBUSY_ ::= 0x8000 // Read: Bit=1 when no conversion is in progress.

  static MUX_MASK_ ::= 0x7000
  static MUX_DIFF_0_1_ ::= 0x0000  // Differential P  =  AIN0, N  =  AIN1 (default).
  static MUX_DIFF_0_3_ ::= 0x1000  // Differential P  =  AIN0, N  =  AIN3.
  static MUX_DIFF_1_3_ ::= 0x2000  // Differential P  =  AIN1, N  =  AIN3.
  static MUX_DIFF_2_3_ ::= 0x3000  // Differential P  =  AIN2, N  =  AIN3.

  static MUX_SINGLE_0_ ::= 0x4000  // Single-ended AIN0.
  static MUX_SINGLE_1_ ::= 0x5000  // Single-ended AIN1.
  static MUX_SINGLE_2_ ::= 0x6000  // Single-ended AIN2.
  static MUX_SINGLE_3_ ::= 0x7000  // Single-ended AIN3.

  static SINGLE_ENDED_ ::= [MUX_SINGLE_0_, MUX_SINGLE_1_, MUX_SINGLE_2_, MUX_SINGLE_3_]


  static PGA_MASK_ ::=   0x0E00
  static PGA_6_144V_ ::= 0x0000  // +/-6.144V range  =  Gain 2/3.
  static PGA_4_096V_ ::= 0x0200  // +/-4.096V range  =  Gain 1.
  static PGA_2_048V_ ::= 0x0400  // +/-2.048V range  =  Gain 2 (default).
  static PGA_1_024V_ ::= 0x0600  // +/-1.024V range  =  Gain 4.
  static PGA_0_512V_ ::= 0x0800  // +/-0.512V range  =  Gain 8.
  static PGA_0_256V_ ::= 0x0A00  // +/-0.256V range  =  Gain 16.

  static MODE_MASK_ ::=   0x0100
  static MODE_CONTIN_ ::= 0x0000  // Continuous conversion mode.
  static MODE_SINGLE_ ::= 0x0100  // Power-down single-shot mode (default).

  static DR_MASK_ ::= 0x00E0     // Values ADS1015/ADS1115.
  static DR_128SPS_ ::= 0x0000   // 128 /8 samples per second.
  static DR_250SPS_ ::= 0x0020   // 250 /16 samples per second.
  static DR_490SPS_ ::= 0x0040   // 490 /32 samples per second.
  static DR_920SPS_ ::= 0x0060   // 920 /64 samples per second.
  static DR_1600SPS_ ::= 0x0080  // 1600/128 samples per second (default).
  static DR_2400SPS_ ::= 0x00A0  // 2400/250 samples per second.
  static DR_3300SPS_ ::= 0x00C0  // 3300/475 samples per second.
  static DR_860SPS_ ::= 0x00E0  // -   /860 samples per Second.

  static CMODE_MASK_ ::= 0x0010
  static CMODE_TRAD_ ::= 0x0000  // Traditional comparator with hysteresis (default).
  static CMODE_WINDOW_ ::= 0x0010  // Window comparator.

  static CPOL_MASK_ ::= 0x0008
  static CPOL_ACTVLOW_ ::= 0x0000  // ALERT/RDY pin is low when active (default).
  static CPOL_ACTVHI_ ::= 0x0008  // ALERT/RDY pin is high when active.

  static CLAT_MASK_ ::= 0x0004  // Determines if ALERT/RDY pin latches once asserted.
  static CLAT_NONLAT_ ::= 0x0000  // Non-latching comparator (default).
  static CLAT_LATCH_ ::= 0x0004  // Latching comparator.

  static CQUE_MASK_ ::= 0x0003
  static CQUE_1CONV_ ::= 0x0000  // Assert ALERT/RDY after one conversions.
  static CQUE_2CONV_ ::= 0x0001  // Assert ALERT/RDY after two conversions.
  static CQUE_4CONV_ ::= 0x0002  // Assert ALERT/RDY after four conversions.
  // Disable the comparator and put ALERT/RDY in high state (default).
  static CQUE_NONE_ ::= 0x0003


  static GAINS_PGA_6_144V_ ::= 0
  static GAINS_PGA_4_096V_ ::= 1  // 1x.
  static GAINS_PGA_2_048V_ ::= 2  // 2x.
  static GAINS_PGA_1_024V_ ::= 3  // 4x.
  static GAINS_PGA_0_512V_ ::= 4  // 8x.
  static GAINS_PGA_0_256V_ ::= 5  // 16x.


  static RATES_DR_8SPS_   ::= 0 // 8 samples per second.
  static RATES_DR_16SPS_  ::= 1 // 16 samples per second.
  static RATES_DR_32SPS_  ::= 2 // 32 samples per second.
  static RATES_DR_64SPS_  ::= 3 // 64 samples per second.
  static RATES_DR_128SPS_ ::= 4 // 128 samples per second (default).
  static RATES_DR_250SPS_ ::= 5 // 250 samples per second.
  static RATES_DR_475SPS_ ::= 6 // 475 samples per second.
  static RATES_DR_860SPS_ ::= 7 // 860 samples per Second.


  static GAINS_TWOTHIRDS_ ::= 6.144
  static GAINS_1X_  ::= 4.096
  static GAINS_2X_  ::= 2.048
  static GAINS_4X_  ::= 1.024
  static GAINS_8X_  ::= 0.512
  static GAINS_16X_ ::= 0.256

  static CHANNELS_MUX_SINGLE_0_ ::= [0, 0]
  static CHANNELS_MUX_SINGLE_1_ ::= [1, 0]
  static CHANNELS_MUX_SINGLE_2_ ::= [2, 0]
  static CHANNELS_MUX_SINGLE_3_ ::= [3, 0]
  static CHANNELS_MUX_DIFF_0_1_ ::= [0, 1]
  static CHANNELS_MUX_DIFF_0_3_ ::= [0, 3]
  static CHANNELS_MUX_DIFF_1_3_ ::= [1, 3]
  static CHANNELS_MUX_DIFF_2_3_ ::= [2, 3]

  static CONVERT_RAW_TO_VOLT_ ::=  4.096 / 32768

  registers_ /serial.Registers ::= ?

  constructor device/serial.Device:
    registers_ = device.registers

  /**
  Reads the voltage on the given channel.

  The voltage range is set to +/- 4.096V.
  */
  read --channel/int -> float:
    raw := read --raw --channel=channel
    return raw * CONVERT_RAW_TO_VOLT_

  /**
  Reads the raw value on the given channel.

  Returns a 16-bit signed integer.
  */
  read --raw/bool --channel/int -> int:
    if not 0 <= channel <= 3: throw "INVALID ARGUMENT"
    if not raw: throw "INVALID ARGUMENT"

    config := 0
        | CQUE_NONE_        // Disable comparator queue.
        | CLAT_NONLAT_      // Don't latch the comparator.
        | CPOL_ACTVLOW_     // Alert/Rdy active low.
        | CMODE_TRAD_       // Traditional comparator.
        | RATES_DR_475SPS_  // 475 samples per second.
        | MODE_SINGLE_      // Single-shot mode.
        | OS_SINGLE_        // Begin a single conversion.
        // When changing this configuration, don't forget to update the toitdoc of $read.
        | PGA_4_096V_       // Range +/- 4.096V.
        | SINGLE_ENDED_[channel]

    write_register_ REGISTER_CONFIG_ config
    while is_busy_: sleep --ms=1
    return registers_.read_i16_be REGISTER_CONVERT_

  is_busy_ -> bool:
    config_value := registers_.read_u16_be REGISTER_CONFIG_
    return config_value & OS_MASK_ == OS_BUSY_

  read_register_ register -> int:
    return registers_.read_u16_be register

  write_register_ register value:
    registers_.write_u16_be register value
