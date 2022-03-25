import SwiftUI

struct GameOverView: View {
    let score: Int
    let moves: Int
    let surveyLink: String
    let action: () -> ()
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HeaderBarTitle(title: "GAME ENDED")
            Text("YOU SCORED:")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.tileEight)
            
            Text("🎉 \(score.description) 🎉")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundColor(.tileDarkTitle)
            
            Text("Number of moves: \(moves)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white50)
			
            if #available(iOS 14.0, *) {
                Link("Survey Link", destination: URL(string: self.surveyLink) ?? URL(string: "https://www.surveymonkey.com/r/69HQVW9")! )
            } else {
                // Fallback on earlier versions
            }
            
            Group {
                ActionButton(title: "NEW GAME", action: action)
            }.padding()
            Spacer()
        }
        .background(Color.white)
    }
}

extension GameOverView {
    private var scoreLabel: Text {
        Text("SCORE: \(score.description)")
            .font(.system(size: 30, weight: .black, design: .rounded))
            .foregroundColor(.red)
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameOverView(score: 12312, moves: 999, surveyLink: "https://www.surveymonkey.com/r/69HQVW9") { }
                .environment(\.colorScheme, .light)
            
            GameOverView(score: 12312, moves: 999, surveyLink: "https://www.surveymonkey.com/r/69HQVW9") { }
                .environment(\.colorScheme, .dark)
        }
    }
}
