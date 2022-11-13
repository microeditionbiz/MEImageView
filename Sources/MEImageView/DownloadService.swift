//
//  DownloadService.swift
//  MEImageView
//
//  Created by Pablo Ezequiel Romero Giovannoni on 30/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

public typealias DownloadServiceCompletion = (_ url: URL,_ localURL: URL,_ error: Error?) -> ()
  
public protocol DownloadOperationProtocol {
    var fromURL: URL {get}
    func cancel()
}

public protocol DownloadServiceProtocol {
    @discardableResult
    func downloadContent(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) -> DownloadOperationProtocol
}

final class DowloadService: DownloadServiceProtocol {
    fileprivate let operationQueue: OperationQueue
    
    init(operationQueue: OperationQueue = .init()) {
        self.operationQueue = operationQueue
        self.operationQueue.maxConcurrentOperationCount = 3
    }
    
    @discardableResult
    func downloadContent(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) -> DownloadOperationProtocol {
        let op = DownloadOperation(fromURL: fromURL, to: localURL, completion: completion)
        operationQueue.addOperation(op)
        return op
    }
}

final class DownloadOperation: AsyncOperation {
    let fromURL: URL
    private let localURL: URL
    private let completion: DownloadServiceCompletion
    private var downloadTask: URLSessionDownloadTask!
    
    init(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) {
        self.fromURL = fromURL
        self.localURL = localURL
        self.completion = completion
    }
    
    override func main() {
        self.downloadTask = URLSession.shared.downloadTask(with: fromURL) { downloadedURL, response, downloadError in
            var completionError: Error?
        
            if let downloadError = downloadError {
                completionError = downloadError
            } else {
                do {
                    try FileSystemHelper.copyFile(from: downloadedURL!, to: self.localURL)
                } catch {
                    completionError = error
                }
            }
            
            DispatchQueue.main.async {
                self.completion(self.fromURL, self.localURL, completionError)
                self.finish()
            }
        }
    
        downloadTask.resume()
    }
    
    override func cancel() {
        downloadTask.cancel()
        super.cancel()
    }
}

extension DownloadOperation: DownloadOperationProtocol { }
