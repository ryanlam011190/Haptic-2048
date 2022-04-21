import SwiftUI

struct LogInView: View {
	@ObservedObject var viewModel: GameViewModel
	@Binding var showLogin: Bool
	@Binding var showConsent:Bool
	@Binding var stopGame:Bool
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
            .keyboardType(.decimalPad)
			
			Button(action: {
				self.viewModel.experimentId = self.experimentId
				self.viewModel.userId = self.userId
				self.viewModel.config_id = self.experimentId
				self.viewModel.configuration?.getConfig()
				self.viewModel.reset()
                if let _ = self.viewModel.configuration?.errorMsg {
                    self.showLogin = true
                } else {
                    self.showConsent = true
                    self.showLogin = false
                }
			}) {
				Text("Start game")
			}
            .disabled(userId.isEmpty || experimentId.isEmpty)
			
			Button(action: {
				self.viewModel.reset()
				self.viewModel.skipGame = true
				self.showLogin = false
			}) {
				Text("Skip >>")
			}
            
            Text(self.viewModel.configuration?.errorMsg ?? "").foregroundColor(Color.red)
		}
	}
}
