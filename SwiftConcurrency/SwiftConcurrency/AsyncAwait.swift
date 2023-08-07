//
//  AsyncAwait.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/08.
//

import SwiftUI

/*
async-await
multi threading
*/

class AsyncAwaitViewModel: ObservableObject {

    @Published var dataArray: [String] = []

    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("title1: \(Thread.current)")
        }
    }

    func addTitle2() {
        // 백그라운드 스레드로 갔다가
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "title2: \(Thread.current)"

            // 메인 스레드로 다시 돌아옴
            DispatchQueue.main.async {
                self.dataArray.append(title)

                let title3 = "title3: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }

    /*
     강의와 달리 메인스레드로 안 나옴
     Class property 'current' is unavailable from asynchronous contexts; Thread.current cannot be used from async contexts
     */
    func addAuthor1() async {
        let author1 = "author1: \(Thread.current)"
        dataArray.append(author1)

        // async 지연시키기
        // await 한다고 해서 무조건 백그라운드 스레드로 가는 것은 아니다. 물론 갈 수도 있음.
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let author2 = "author2: \(Thread.current)"

        await MainActor.run {
            dataArray.append(author2)

            let author3 = "author3: \(Thread.current)"
            dataArray.append(author3)
        }

        await addSomething()
    }

    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let something1 = "something1: \(Thread.current)"

        await MainActor.run {
            dataArray.append(something1)

            let something2 = "something2: \(Thread.current)"
            dataArray.append(something2)
        }
    }
}

struct AsyncAwait: View {

    @StateObject private var viewModel = AsyncAwaitViewModel()

    var body: some View {
        List(viewModel.dataArray, id: \.self) { data in
            Text(data)
        }
        .onAppear {
//            viewModel.addTitle1()
//            viewModel.addTitle2()

            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()

                let finalText = "Final: \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
