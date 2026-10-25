# NorgeSpoof
SwiftUI app: Norway map, joystick, speed slider, place search, pairing-file import.

## Build
1. Push this folder to a GitHub repo. Actions > "Build IPA" > download the unsigned NorgeSpoof.ipa.
2. Sign/install it with your Apple ID (SideStore / AltStore / Sideloadly).

## Use
Enable Developer Mode, start LocalDevVPN, open the app, import your pairing file, tap Start.

## Still to do
Sources/LocationSimulator.swift: IdeviceLocationSimulator is a stub. Wire it to the `idevice`
library (add it as a Swift package in project.yml) to call the simulate-location service.
