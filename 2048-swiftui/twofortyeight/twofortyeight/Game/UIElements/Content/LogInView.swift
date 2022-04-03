import SwiftUI

struct LogInView: View {
	@ObservedObject var viewModel: GameViewModel
	@Binding var startGame: Bool
	@State private var userId: String = ""
	@State private var experimentId: String = ""
	
	var body: some View {
		VStack(alignment: .center, spacing: 20) {
			HeaderBarTitle(title: "2048 HAPTICS GAME", size: 20)
			
			Text("User id")
			TextField(
				"User id",
				text: $userId
			)
			.font(Font.system(size: 12))
			.background(RoundedRectangle(cornerRadius: 10).fill(Color.clear))
			.padding()
			.textFieldStyle(.roundedBorder)
			
			Text("Experiment id")
			TextField(
				"Experiment id",
				text: $experimentId
			)
			.font(Font.system(size: 12))
			.background(RoundedRectangle(cornerRadius: 10).fill(Color.clear))
			.padding()
			.textFieldStyle(.roundedBorder)
			
			Button(action: {
				// Your auth logic
				self.viewModel.reset()
				self.startGame = true
			}) {
				Text("Sign in")
			}
		}
	}
}
