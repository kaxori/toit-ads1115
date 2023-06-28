// Copyright (C) 2023 kaxori.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import i2c
import gpio
import ads1115 show *

main:
    i2cBus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22
      --frequency=10_000

    i2cBusDevice := i2cBus.device 0x48
    ads1115 := ADS1115 i2cBusDevice

    CONVERT_RAW_TO_VOLT ::=  4.096 / 32768

    while true:
        msg := "ADC[0...3]: "
        4.repeat:
            msg += "\t$(%2.3f (ads1115.readChannel it)* CONVERT_RAW_TO_VOLT) "
        
        print msg
    sleep --ms=1000