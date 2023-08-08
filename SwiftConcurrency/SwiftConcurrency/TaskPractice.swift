//
//  TaskPractic.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/08.
//

import SwiftUI

class TaskPracticeViewModel: ObservableObject {

    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil

    func fetchImage() async {
//        for x in array {
//            try Task.checkCancellation() // 취소되는 작업에 대한 확인 
//        }

        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                self.image = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            self.image2 = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskPractice: View {

    @StateObject private var viewModel = TaskPracticeViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
//            1.
//            Task {
//                await viewModel.fetchImage()
//                await viewModel.fetchImage2()
//            }

//            2.
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }

//            3. 우선 순위 (높은순!)
            // 동일한 스레드에서 실행되는 작업은 우선 순위를 지킴
//            Task(priority: .high) {
////                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                await Task.yield()
//                print("HIGH: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .userInitiated) {
//                print("USERINITIATED: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .medium) {
//                print("MEDIUM: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .low) {
//                print("LOW: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .utility) {
//                print("UTILITY: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .background) {
//                print("BACKGROUND: \(Thread.current) : \(Task.currentPriority)")
//            }

//            4. 우선순위2 - 동일한 우선순위
//            Task(priority: .userInitiated) {
//                print("USERINITIATED: \(Thread.current) : \(Task.currentPriority)")
//
//                Task {
//                    print("USERINITIATED2: \(Thread.current) : \(Task.currentPriority)")
//                }
//            }

//            Task(priority: .low) {
//                print("LOW: \(Thread.current) : \(Task.currentPriority)")
//
//                // but 공식 문서 - 가능한한 task를 분리하여 사용하지 마삼요
//                Task.detached {
//                    print("Detached: \(Thread.current) : \(Task.currentPriority)")
//
//                }
//            }

//            Task(priority: .low) {
//                print("LOW: \(Thread.current) : \(Task.currentPriority)")
//
//                // but 공식 문서 - 가능한한 task를 분리하여 사용하지 마삼요
//                Task(priority: .background) {
//                    print("BACKGROUND: \(Thread.current) : \(Task.currentPriority)")
//
//                }
//            }

//            5. 더이상 필요하지 않은 작업 취소하기 -> ex. 뒤로 버튼을 눌렀을 때 로딩되는 행위를 취소
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }

//            6. 작업을 취소해도 작업의 작업은 계속 돌 수도 -> 코드의 cancel을 확읺

        }
//        .onDisappear {
//            // 작업이 완료된 이후에는 cancelled message가 뜨지 않지만, 작업이 완료되지 않았는데 뒤로가기를 누른 경우 cancelled message가 뜸
//            fetchImageTask?.cancel()
//        }
        .task {
            /*
             onAppear {
                Task { ... } 의 역할을 함
             }
             ⭐️ 작업이 완료되기 전에 뷰가 사라지면 자동으로 작업을 취소
             */
            await viewModel.fetchImage()
        }
    }
}

struct TaskHomeView: View {

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink {
                    TaskPractice()
                } label: {
                    Text("Click Me! 😁")
                }

            }
        }
    }
}

struct TaskPractic_Previews: PreviewProvider {
    static var previews: some View {
        TaskPractice()
    }
}
