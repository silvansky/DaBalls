//

import Foundation
import AudioKit
import Tonic

extension Key {
    func note(with number: Int, startingOctave: Int = 2) -> Note {
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


class AudioController
{
    static let shared = AudioController()
    private var instrument = MIDISampler(name: "Instrument 1")
    private var reverb: Reverb
    private let engine: AudioEngine = .init()
    private let mixer: Mixer = .init()
    private let key: Key = Key(root: NoteClass(.C), scale: .pentatonicNeutral)

    private init() {
        reverb = Reverb(instrument, dryWetMix: 0.3)
        mixer.addInput(reverb)
        engine.output = mixer
        startEngine()
    }

    func playNote(_ number: Int) {
        let note = key.note(with: number).pitch.midiNoteNumber
        instrument.play(noteNumber: MIDINoteNumber(note), velocity: 90, channel: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.instrument.stop(noteNumber: MIDINoteNumber(note), channel: 0)
        }
    }

    func nameForNote(_ number: Int) -> String {
        return key.note(with: number).noteClass.description
    }
}

extension AudioController {
    private func startEngine() {
        do {
            //try Settings.session.setActive(true)
            try engine.start()
            do {
                if let fileURL = Bundle.main.url(forResource: "HS Acoustic Percussion", withExtension: "sf2") {
                    try instrument.loadInstrument(url: fileURL)
                } else {
                    Log("Could not find file")
                }
            } catch {
                Log("Could not load instrument: \(error)")
            }
        } catch {
            Log("Failed to start engine: \(error)")
        }
    }
}
