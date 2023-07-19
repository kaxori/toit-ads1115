# ADS1115

Toit driver for the ADS1115, a 4 channel high-resolution analog to digital converter.

# Installation

```bash
jag pkg install github.com/kaxori/toit-ads1115
```

# Usage

```toit
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
```

## Resources

* Datasheet: https://www.ti.com/lit/ds/symlink/ads1115.pdf
* Adafruit's document on their breakout board: https://cdn-learn.adafruit.com/downloads/pdf/adafruit-4-channel-adc-breakouts.pdf
