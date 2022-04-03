import Combine
import UIKit
import LofeltHaptics

class GameViewModel: ObservableObject {
    private(set) var engine: Engine
    private(set) var storage: Storage
    private(set) var stateTracker: StateTracker
    private var haptics: LofeltHaptics?
    private var hapticDataShort: NSString?
    private var hapticDataLong: NSString?
    public var surveyLink: String = "https://www.surveymonkey.com/r/69HQVW9"
	
	public var MAX_SCORE = 10
  
    @Published var isGameOver = false {
        didSet {
            if isGameOver { self.playHaptic(hapticData: self.hapticDataLong) }
        }
    }
    
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
			isGameOver = (state.score > MAX_SCORE || engine.isGameOver(state.board))
            storage.save(board: state.board)
        }
    }
    
    init(_ engine: Engine, storage: Storage, stateTracker: StateTracker) {
        self.engine = engine
        self.storage = storage
        self.stateTracker = stateTracker
        self.state = stateTracker.last
        self.bestScore = max(storage.bestScore, storage.score)
        getConfig()
    }
	
	func getConfig() {
		let url = URL(string: "https://haptics-test.herokuapp.com/config/getConfig")!
		var request = URLRequest(url: url)
		let config_id = "config_24532"
		let bodyData = try? JSONSerialization.data(
			withJSONObject: [
				"config_id": config_id
			],
			options: []
		)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = bodyData
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			
			guard let data = data, error == nil else {
				return
			}

			do {
				let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
				if let dictionary = jsonObject {
					if let str = dictionary["max_score"] as? String, let max_score = Int(str) {
						self.MAX_SCORE = Int(max_score)
					}
                    print(dictionary)
                    if let str = dictionary["short_haptics_file"] as? String,
                        let shortUrl = URL(string: str),
                        let str1 = dictionary["long_haptics_file"] as? String,
                        let longUrl = URL(string: str1) {
                        self.setupHaptics(shortUrl: shortUrl, longUrl: longUrl)
                    }
                    if let str = dictionary["survey_link"] as? String {
                        self.surveyLink = str
                    } else {
                        self.surveyLink = "https://www.surveymonkey.com/r/69HQVW9"
                    }
				}
			} catch let parseError {
				print("JSON Error \(parseError.localizedDescription)")
			}
			
		}
		task.resume()
	}
    
    func start() {
        if state.board.isMatrixEmpty { reset() }
    }
    
    func setupHaptics(shortUrl: URL, longUrl: URL) {
        do {
            self.haptics = try LofeltHaptics.init()
        } catch let error{
            print("Lofelt Haptics Engine Creation Error: \(error)")
            return
        }
        let downloadTask = URLSession.shared.downloadTask(with: shortUrl) {
            urlOrNil, responseOrNil, errorOrNil in
            // check for and handle errors:
            // * errorOrNil should be nil
            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
            
            guard let fileURL = urlOrNil else { return }
            do {
                try self.hapticDataShort = NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print ("Error Downloading Short Haptic from Aws: \(error)")
            }
        }
        downloadTask.resume()
        
        let downloadTaskLong = URLSession.shared.downloadTask(with: longUrl) {
            urlOrNil, responseOrNil, errorOrNil in
            // check for and handle errors:
            // * errorOrNil should be nil
            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
            
            guard let fileURL = urlOrNil else { return }
            do {
                try self.hapticDataLong = NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print ("Error Downloading Short Haptic from Aws: \(error)")
            }
        }
        downloadTaskLong.resume()
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
            //playHaptic(hapticData: self.hapticDataShort)
        }
    }
    
    func playHaptic(hapticData: NSString?) {
        // Load it into the LofeltHaptics object as a String.
        guard let haptics = self.haptics else {
            print("unable to use haptics object")
            return
        }
        guard let hapticData = hapticData else { return }
        do {
            try haptics.load(hapticData as String)
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
