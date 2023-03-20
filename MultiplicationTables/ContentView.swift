//
//  ContentView.swift
//  MultiplicationTables
//
//  Created by Maximilian Berndt on 2023/03/19.
//

import SwiftUI


// This is a reusable number formatter
extension Formatter {
    static let emptyNumberFormat: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.zeroSymbol  = ""     // Show empty string instead of zero
        return formatter
    }()
}

struct ContentView: View {
    
    enum GameState {
        case settings
        case game
    }
    
    @State private var selectedMaxTables = 2.0
    
    private var questionOptions = [1, 5, 10, 20]
    @State private var selectedQuestionAmount = 1
    
    @State private var state: GameState = .settings
    
    @State private var currentQuestionLeftSide = 2
    @State private var currentQuestionRightSide = 2
    @State private var answer: Int = 0
    @State private var hasAnswered: Bool = false
    
    @State private var score = 0
    @State private var questionsAsked = 0
    
    @FocusState private var answerIsFocused: Bool
    
    @State private var showingFinalScore = false
    
    private var isCorrectAnswer: Bool {
        return answer == (currentQuestionLeftSide * currentQuestionRightSide)
    }
    
    var body: some View {
        ZStack {
            Form {
                Section("Select Multiplication Limit") {
                    Stepper(
                        "\(selectedMaxTables.formatted())",
                        value: $selectedMaxTables,
                        in: 2...12,
                        format: .number
                    )
                }
                Section("Select Question Amount") {
                    Picker("Questions", selection: $selectedQuestionAmount) {
                        ForEach(questionOptions, id: \.self) {
                            Text($0, format: .number)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Button("Start Game") {
                    state = .game
                    answerIsFocused = true
                    askQuestion()
                }
            }
            .opacity(state == .settings ? 1 : 0)
            .animation(.default, value: state)
            VStack(alignment: .center) {
                Text("Question Time")
                    .font(.title)
                Text("\(currentQuestionLeftSide) x \(currentQuestionRightSide)")
                    .font(.title)
                Spacer()
                TextField(
                    "Answer",
                    value: $answer,
                    formatter: NumberFormatter.emptyNumberFormat
                )
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($answerIsFocused)
                .background(answerBackgroundColor())
                .cornerRadius(12)
                .onSubmit {
                    validateAnswer()
                }
                .font(.largeTitle)
                Spacer()
                Text("Score: \(score)")
                    .font(.title)
            }
            .opacity(state == .game ? 1 : 0)
            .animation(.default, value: state)
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if hasAnswered == false {
                        Button("Submit") {
                            validateAnswer()
                        }
                    } else {
                        Button("Next") {
                            answer = .zero
                            askQuestion()
                        }
                    }
                }
            }
            .opacity(state == .game ? 1 : 0)
            .alert("Well done!", isPresented: $showingFinalScore) {
                Button("Back to settings", action: resetGame)
            } message: {
                Text("Your final score is \(score)")
            }
        }
    }
    
    private func askQuestion() {
        answerIsFocused = true
        answer = .zero // doesn't work!
        hasAnswered = false
        currentQuestionLeftSide = Int.random(in: 2...Int(selectedMaxTables))
        currentQuestionRightSide = Int.random(in: 2..<12)
        questionsAsked += 1
    }
    
    private func validateAnswer() {
        score += isCorrectAnswer ? 1 : 0
        
        if questionsAsked == selectedQuestionAmount {
            showingFinalScore = true
        }
        
        hasAnswered = true
    }
    
    private func resetGame() {
        answerIsFocused = false
        score = 0
        answer = .zero // doesn't work
        hasAnswered = false
        questionsAsked = 0
        state = .settings
    }
    
    private func answerBackgroundColor() -> Color {
        print("hasAnswered: \(hasAnswered)")
        print("isCorretAnswer: \(isCorrectAnswer)")
        guard hasAnswered else { return .white }
        return isCorrectAnswer ? .green : .red
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
