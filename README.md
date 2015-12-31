# Node.js CLI Tool for Launching Sphero Programs

This is a [node.js](http://nodejs.org/) command-line tool for uploading
[macro](http://sdk.sphero.com/robot-languages/macros/) or
[orbBasic](http://sdk.sphero.com/robot-languages/orbbasic/) programs
to Sphero robots.

The communication with the Spheros is delegated to the
[sphero-pwn package](https://github.com/pwnall/node-sphero-pwn). Macros are
compiled using the
[sphero-pwn macro compiler](https://github.com/pwnall/node-sphero-pwn-macros).

This project is written in [CoffeeScript](http://coffeescript.org/) and does
not currently have an automated testing suite.


## Usage

NOTE: This piece of code was hacked up together for a demo. The interface and
functionality might change dramatically over time.

Discover the robots around you and note their identifiers.

```bash
npm start

# Discovered Sphero: serial:///dev/cu.Bluetooth-Incoming-Port
# Discovered Sphero: serial:///dev/cu.Sphero-YRG-AMP-SPP
# Discovered Sphero: ble://ef:80:a8:4a:12:34
# Discovered Sphero: ble://dc:2d:00:6d:12:34
```

Launch an orbBasic program on a robot.

```bash
npm start serial:///dev/cu.Sphero-YRG-AMP-SPP examples/print.bas
```

Compile and launch a macro program on a robot.

```bash
npm start ble://ef:80:a8:4a:12:34 examples/markers.bas
```

Launch a program on multiple robots at the same time by separating the robot
identifiers with a comma (`,`).

```bash
npm start ble://ef:80:a8:4a:12:34,ble://dc:2d:00:6d:12:34 examples/markers.bas
```


## License

This project is Copyright (c) 2015 Victor Costan, and distributed under the MIT
License.
