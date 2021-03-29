//
//  WordData.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa

enum WordDataError: String, Error {
    case pathError = "Error: 路徑錯誤啦"
    case transformError = "Error: 轉換資料有問題"
}

class WordData {
    func createData() -> Single<[String]> {
        return Single.create { (single) -> Disposable in
            
            if let path = Bundle.main.path(forResource: "CapitalWord", ofType: ".txt") {
                do {
                    let content = try String(contentsOfFile: path, encoding: .utf8)
                    var allContent = content.components(separatedBy: "\n")
                    allContent.removeLast()
                    single(.success(allContent))
                } catch {
                    single(.failure(WordDataError.transformError))
                }
            } else {
                single(.failure(WordDataError.pathError))
            }
            return Disposables.create()
        }
    }
}
