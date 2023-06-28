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
```
