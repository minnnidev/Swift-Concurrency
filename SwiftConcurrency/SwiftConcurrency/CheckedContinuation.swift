//
//  CheckedContinuation.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/14.
//

import SwiftUI

/*
Continuation
async await 기능을 업데이트하지 않은 sdk나 api를 async await으로 변환해 보기
*/

class CheckedContinuationNetworkManager {

    func getData(url: URL) async throws -> Data {
        do {
            // 비동기 처리가 적용되어 있는 URLSession의 데이터 메소드
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            throw error
        }
    }

    /* 
     Checked(Throwing)Continuation - 작업이 여러번 resume되는지 체크
     Unsafe(Throwing)Continuation - 오버헤드를 줄이기 위해 체크 안 함

     continuation.resume()으로 비동기적 리턴
     resume은 단 한번 호출되어야 함
     두 번 이상 호출되면 예상치 못한 동작이 발생할 수도 있음
     애초에 두 번 이상 사용하면 에러가 뜸
     --------------------------------------------------------------------------------------
     2023-08-15 00:44:26.744950+0900 SwiftConcurrency[90875:7111357] _Concurrency/CheckedContinuation.swift:167: Fatal error: SWIFT TASK CONTINUATION MISUSE: getData2(url:) tried to resume its continuation more than once, returning 4821 bytes!
     --------------------------------------------------------------------------------------

     resume을 해 주지 않아도 에러가 뜸!
     --------------------------------------------------------------------------------------
     SWIFT TASK CONTINUATION MISUSE: getData2(url:) leaked its continuation!
     2023-08-15 00:46:02.806619+0900 SwiftConcurrency[90975:7114570] SWIFT TASK CONTINUATION MISUSE: getData2(url:) leaked its continuation!
     --------------------------------------------------------------------------------------
     */

    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            // completionHandler를 사용하는 dataTask 메소드
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }

    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }

    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationViewModel: ObservableObject {

    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManager()

    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }

        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error)
        }
    }

    func getHeartImage() async {
//        networkManager.getHeartImageFromDatabase { [weak self] image in
//            self?.image = image
//        }

        self.image = await networkManager.getHeartImageFromDatabase()
    }
}

struct CheckedContinuation: View {

    @StateObject private var viewModel = CheckedContinuationViewModel()

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getImage()
//            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}
