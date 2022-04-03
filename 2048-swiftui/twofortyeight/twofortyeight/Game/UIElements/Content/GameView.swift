import SwiftUI

struct GameEntry: View {
	@ObservedObject var viewModel: GameViewModel
	@State var startGame:Bool = false
	@State var stopGame:Bool = false
	
	var body: some View {
		return VStack {
			if !startGame {
				LogInView(viewModel: viewModel, startGame: $startGame)
			}
			else if viewModel.isGameOver {
				GameOverView(score: self.viewModel.state.score, moves: self.viewModel.numberOfMoves, surveyLink: self.viewModel.surveyLink) {
					self.viewModel.reset()
				}
			}
			else {
				GameView(startGame: $startGame, viewModel: viewModel)
			}
		}
	}
}

struct GameView: View {
	@Binding var startGame: Bool
	@ObservedObject var viewModel: GameViewModel
	@State var showMenu = false
	
	var body: some View {
		VStack(alignment: .center, spacing: 16) {
			Header(score: viewModel.state.score, bestScore: viewModel.MAX_SCORE, menuAction: {
				self.showMenu.toggle()
			}, undoAction: {
				self.viewModel.undo()
			}, undoEnabled: self.viewModel.isUndoable)
			GoalText()
			MaxScore(viewModel: viewModel)
			Board(board: viewModel.state.board, addedTile: viewModel.addedTile)
			Moves(viewModel.numberOfMoves)
		}
		.frame(minWidth: .zero,
			   maxWidth: .infinity,
			   minHeight: .zero,
			   maxHeight: .infinity,
			   alignment: .center)
			.background(Color.gameBackground)
			.background(Menu())
			.edgesIgnoringSafeArea(.all)
	}
}

extension GameView {
	
	private func Menu() -> some View {
		EmptyView().sheet(isPresented: $showMenu) {
			MenuView(newGameAction: {
				self.viewModel.reset()
				self.showMenu.toggle()
			}, resetScoreAction: {
				self.viewModel.eraseBestScore()
				self.showMenu.toggle()
			})
		}
	}
	
	private func GameOver() -> some View {
		EmptyView().sheet(isPresented: $viewModel.isGameOver) {
			GameOverView(score: self.viewModel.state.score, moves: self.viewModel.numberOfMoves, surveyLink: self.viewModel.surveyLink) {
				self.viewModel.reset()
			}
		}
	}
}

struct GameView_Previews: PreviewProvider {
	static var previews: some View {
		@State var startGame:Bool = false
		let engine = GameEngine()
		let storage = LocalStorage()
		let stateTracker = GameStateTracker(initialState: (storage.board ?? engine.blankBoard, storage.score))
		return GameView(startGame: $startGame, viewModel: GameViewModel(engine, storage: storage, stateTracker: stateTracker))
	}
}
