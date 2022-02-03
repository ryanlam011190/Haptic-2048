import Combine
import UIKit
import LofeltHaptics

class GameViewModel: ObservableObject {
    private(set) var engine: Engine
    private(set) var storage: Storage
    private(set) var stateTracker: StateTracker
    private var haptics: LofeltHaptics?
    private var hapticClip: NSDataAsset?
    private var hapticData: NSString?
  
    @Published var isGameOver = false
    private(set) var addedTile: (Int, Int)? = nil {
        didSet { UIImpactFeedbackGenerator().impactOccurred() }
    }
    private(set) var bestScore: Int = .zero {
        didSet { storage.save(bestScore: bestScore) }
    }
    
    var numberOfMoves: Int {
        return stateTracker.statesCount - 1
    }
    var isUndoable: Bool {
        return stateTracker.isUndoable
    }
    var state: GameState {
        didSet {
            bestScore = max(bestScore, state.score)
            storage.save(score: state.score)
            isGameOver = engine.isGameOver(state.board)
            storage.save(board: state.board)
        }
    }
    
    init(_ engine: Engine, storage: Storage, stateTracker: StateTracker) {
        self.engine = engine
        self.storage = storage
        self.stateTracker = stateTracker
        self.state = stateTracker.last
        self.bestScore = max(storage.bestScore, storage.score)
        do {
            self.haptics = try LofeltHaptics.init()
        } catch let error{
            print("Engine Creation Error: \(error)")
        }
        self.hapticClip = NSDataAsset(name: "Achievement_1.haptic")
        if let hapticClip = self.hapticClip {
            self.hapticData = NSString(data: hapticClip.data , encoding: String.Encoding.utf8.rawValue)
        }
    }
    
    func start() {
        if state.board.isMatrixEmpty { reset() }
    }
    
    func addNumber() {
        let result = engine.addNumber(state.board)
        state = stateTracker.updateCurrent(with: result.newBoard)
        addedTile = result.addedTile
    }
    
    func push(_ direction: Direction) {
        let result = engine.push(state.board, to: direction)
        let boardHasChanged = !state.board.isEqual(result.newBoard)
        state = stateTracker.next(with: (result.newBoard, state.score + result.scoredPoints))
        if boardHasChanged {
            addNumber()
            playHaptic()
        }
    }
    
    func playHaptic() {
        // Load it into the LofeltHaptics object as a String.
        guard let haptics = self.haptics else {
            print("unable to use haptics object")
            return
        }
        do {
            try haptics.load(hapticData! as String)
            // Play audio and haptics (audio must be played first).
            //audioPlayer?.play() //is audio needed for this project?
            try haptics.play()
            print("Success!")
        } catch {
            print("Could not play haptic clip")
        }
        
    }
    
    func undo() {
        state = stateTracker.undo()
    }
    
    func reset() {
        state = stateTracker.reset(with: (engine.blankBoard, .zero))
        addNumber()
    }
    
    func eraseBestScore() {
        bestScore = .zero
    }
    
}
