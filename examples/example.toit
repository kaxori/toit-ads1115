// Copyright (C) 2023 kaxori.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import i2c
import gpio
import ads1115 show *

main:
  bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22
      --frequency=10_000

  device := bus.device Ads1115.I2C_ADDRESS
  ads1115 := Ads1115 device

  while true:
    msg := "ADC[0...3]: "
    4.repeat:
      channel_value := ads1115.read --channel=it
      msg += "\t$channel_value"
    print msg
    sleep --ms=1000
