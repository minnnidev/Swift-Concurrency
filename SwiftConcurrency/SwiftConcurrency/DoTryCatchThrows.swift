//
//  DoTryCatchThrows.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/08.
//

import SwiftUI

/*
do-catch
try
throws
*/

class DoTryCatchThrowsDataManager {

    let isActive = true

    // 1. nil을 반환하기
//    func getTitle() -> String? {
//        if isActive {
//            return "New Text!"
//        } else {
//            return nil // nil을 반환하는 대신 오류를 반환해 보자!
//        }
//    }

    // 2. 오류를 반환해 보자
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New Text!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }

    // 3. 오류 반환 + 결과 하나만 리턴하도록
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text!")
        } else {
            return .failure(URLError(.badURL))
        }
    }

    // 4.
    // isActive일 때 데이터를 발생하는 데 문제가 발생한다면? return이 String인데 어떻게 처리할까여
    // String을 반환하거나, 오류를 던진다 -> throws / throw
    func getTitle3() throws -> String {
//        if isActive {
//            return "New Text!"
//        } else {
            throw URLError(.badServerResponse)
//        }
    }

    // 5.
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoTryCatchThrowsViewModel: ObservableObject {

    @Published var text = "Starting Text"
    let manager = DoTryCatchThrowsDataManager()

//    1
//    func fetchTitle() {
//        let newTitle = manager.getTitle()
//        if let newTitle = newTitle {
//            text = newTitle
//        }
//    }

//    2
//    func fetchTitle() {
//        let value = manager.getTitle()
//        if let newTitle = value.title {
//            text = newTitle
//        } else if let error = value.error {
//            text = error.localizedDescription
//        }
//    }

//  3
//    func fetchTitle() {
//        let result = manager.getTitle2()
//
//        switch result {
//        case .success(let newTitle):
//            text = newTitle
//        case .failure(let error):
//            text = error.localizedDescription
//        }
//    }

//    4
    func fetchTitle() {
        // try - getTitle3()의 결과를 받으려고 try한다
//        do {
//            // do block 안에 여러 try 구문을 사용할 수 있지만, 실패하면 즉시 do 블록 종료 -> catch 블록으로 점프
//            let newTitle = try manager.getTitle3()
//            text = newTitle
//
//            let finalTitle = try manager.getTitle4()
//            text = finalTitle
//        } catch {
//            text = error.localizedDescription
//        }

        // try? - 선택적 try, 실패하면 어떤 오류를 던지든지 nil을 반환
        // do-catch 구문을 사용할 필요가 없음
        // 오류에 대해서 신경을 쓰지 않아도 된다면 시간이 절약될 수 있음
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            text = newTitle
//        }

        // try? + do-catch
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                text = newTitle
            }
        } catch { // 오류가 발생해도 catch 블록으로 이동하지 않음
            text = error.localizedDescription
        }
    }
}

struct DoTryCatchThrows: View {

    @StateObject private var viewModel = DoTryCatchThrowsViewModel()

    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoTryCatchThrows_Previews: PreviewProvider {
    static var previews: some View {
        DoTryCatchThrows()
    }
}
