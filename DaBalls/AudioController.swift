//

import Foundation
import AudioKit
import AudioKitEX
import CAudioKitEX
import SoundpipeAudioKit
import Tonic

extension Key {
    func note(with number: Int, startingOctave: Int = 1) -> Note {
        let notes = scale.intervals.map { i in
            root.canonicalNote.shiftUp(i)
        }

        var index = number % notes.count
        var octaveShift = number / notes.count
        if index < 0 {
            octaveShift -= 1
            index = index + notes.count
        }
        var note = notes[index]!
        note.octave = startingOctave + octaveShift
        return note
    }
}

class BallOscillator {
    var node: Node { fader }
    private(set) var isStarted: Bool = false
    private let panner: Panner
    private let oscillator: Oscillator
    private let fader: Fader
    private let rampDuration: Float = 0.1

    init() {
        self.oscillator = Oscillator()
        self.panner = Panner(oscillator)
        self.fader = Fader(panner, gain: 0.0)
        oscillator.start()
    }

    func update(_ ballPosition: CGPoint, rect: CGRect) {
        // Calc frequency from x position
        let minFrequency: AUValue = 80
        let maxFrequency: AUValue = 800
        let x = AUValue(ballPosition.x)
        let halfWidth = AUValue(rect.width / 2)
        let k = (halfWidth + x) / AUValue(rect.width)
        let freq: AUValue = minFrequency + k * (maxFrequency - minFrequency)

        // Calc amplitude from y position
        let y = AUValue(ballPosition.y)
        let maxAmplitude: AUValue = 0.1
        let halfHeight = AUValue(rect.height / 2)
        let j = (halfHeight + y) / AUValue(rect.height)
        let amplitude: AUValue = maxAmplitude * j

        // Calculate pan based on x position
        let pan = AUValue(ballPosition.x / (rect.width / 2))

        oscillator.frequency = freq
        oscillator.amplitude = amplitude
        panner.pan = pan
    }

    func start() {
        isStarted = true
        let finish = AutomationEvent(targetValue: 1, startTime: 0, rampDuration: rampDuration)
        fader.automateGain(events: [finish])
    }

    func stop() {
        isStarted = false
        let finish = AutomationEvent(targetValue: 0, startTime: 0, rampDuration: rampDuration)
        fader.automateGain(events: [finish])
    }
}

class AudioController
{
    static let shared = AudioController()
    //private var instrument = MIDISampler(name: "Instrument 1")
    private var instruments: [MIDISampler] = []
    private var reverb: Reverb
    private let engine: AudioEngine = .init()
    private let mixer: Mixer = .init()
    private let key: Key = Key(root: NoteClass(.G), scale: .chromatic)
    private var oscillators: [Int: BallOscillator] = [:]

    private init() {
        reverb = Reverb(mixer, dryWetMix: 0.3)
        engine.output = reverb
        startEngine()
    }

    // Pan is [-1, 1] where -1 is left and 1 is right
    func playNote(_ number: Int, pan: Float = 0, velocity: MIDIVelocity = 90) {
        let note = key.note(with: number).pitch.midiNoteNumber
        guard let instrument = instruments.min(by: { abs($0.pan - pan) < abs($1.pan - pan) }) else {
            Log("No instrument available to play note \(note)")
            return
        }

        instrument.play(noteNumber: MIDINoteNumber(note), velocity: velocity, channel: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            instrument.stop(noteNumber: MIDINoteNumber(note), channel: 0)
        }
    }

    func nameForNote(_ number: Int) -> String {
        return key.note(with: number).noteClass.description
    }

    func addOscillator(for ballId: Int) {
        let oscillator = BallOscillator()
        oscillators[ballId] = oscillator
        mixer.addInput(oscillator.node)
    }

    func updateOscillator(_ ballId: Int, position: CGPoint, rect: CGRect) {
        guard let oscillator = oscillators[ballId] else {
            Log("No oscillator found for ballId \(ballId)")
            return
        }

        oscillator.update(position, rect: rect)
    }

    func stopOscillator(_ ballId: Int) {
        guard let oscillator = oscillators[ballId] else {
            Log("No oscillator found for ballId \(ballId)")
            return
        }
        oscillator.stop()
    }

    func switchOscillator(_ ballId: Int) {
        guard let oscillator = oscillators[ballId] else {
            Log("No oscillator found for ballId \(ballId)")
            return
        }

        if oscillator.isStarted {
            oscillator.stop()
        } else {
            oscillator.start()
        }
    }
}

extension AudioController {
    private func startEngine() {
        do {
            //try Settings.session.setActive(true)
            try engine.start()
            createInstruments()
        } catch {
            Log("Failed to start engine: \(error)")
        }
    }

    private func createInstruments() {
        guard let fileURL = Bundle.main.url(forResource: "HS Acoustic Percussion", withExtension: "sf2") else {
            Log("Could not find file")
            return
        }
        do {
            try addInstrument(fileURL: fileURL, name: "Left", pan: -0.8)
            try addInstrument(fileURL: fileURL, name: "Center-Left", pan: -0.4)
            try addInstrument(fileURL: fileURL, name: "Center", pan: 0)
            try addInstrument(fileURL: fileURL, name: "Center-Right", pan: 0.4)
            try addInstrument(fileURL: fileURL, name: "Right", pan: 0.8)
        } catch {
            Log("Could not load instrument: \(error)")
        }
    }

    private func addInstrument(fileURL: URL, name: String, pan: Float) throws {
        let i = MIDISampler(name: "Instrument \(name)")
        mixer.addInput(i)
        try i.loadInstrument(url: fileURL)
        i.pan = pan
        instruments.append(i)
    }
}
