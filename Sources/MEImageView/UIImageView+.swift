//
//  UIImageView+.swift
//  MEImageView
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var ImageURL = "ImageURL"
}

public struct RemoteImageViewConfiguration {
    public let defaultImage: UIImage?
    public let downloadService: DownloadServiceProtocol!

    public init(defaultImage: UIImage?, downloadService: DownloadServiceProtocol!) {
        self.defaultImage = defaultImage
        self.downloadService = downloadService
    }
}

public extension RemoteImageViewConfiguration {
    static var live: Self {
        .init(
            defaultImage: nil,
            downloadService: DowloadService()
        )
    }
}

public var CurrentRemoteImageViewConfiguration: RemoteImageViewConfiguration = .live

extension UIImageView {
    
    typealias CompletionClosure = ((URL?, Error?) -> Void)
    static private let spinnerTag = 999
    
    private var spinner: UIActivityIndicatorView? {
        return viewWithTag(Self.spinnerTag) as? UIActivityIndicatorView
    }
    
    private var imageURL: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImageURL) as? URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImageURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setImageURL(_ url: URL?) {
        guard hasToRefreshContent(for: url) else { return }
        cleanCurrentConfiguration()
       
        guard let url = url else { return }
        imageURL = url
    
        guard let image = cachedImage(for: url) else {
            loadImage(from: url)
            return
        }
        
        self.image = image
    }
    
    private func loadImage(from url: URL) {
        presentLoadingMode()
        let localUrl = localCachedImageUrl(for: url)
                 
        CurrentRemoteImageViewConfiguration.downloadService.downloadContent(fromURL: url, to: localUrl) { (remoteUrl: URL, localUrl: URL, error: Error?) in
            self.removeLoadingMode()
            if error != nil {
                self.presentErrorMode()
            } else {
                if let currentUrl = self.imageURL, currentUrl == url {
                    print("downloaded \(url) to \(localUrl)")
                    self.image = self.cachedImage(for: url)
                }
            }
        }
    }
    
    private func hasToRefreshContent(for newUrl: URL?) -> Bool {
        if image == nil {
            return true
        } else {
            if let currentURL = imageURL {
                return currentURL != newUrl
            } else {
                return true
            }
        }
    }
    
    // MARK: - Cache
    
    private func cachedImage(for remoteUrl: URL) -> UIImage? {
        let localUrl = localCachedImageUrl(for: remoteUrl)
        if FileSystemHelper.fileExist(at: localUrl) {
            let path = localUrl.path
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    private func localCachedImageUrl(for remoteUrl: URL) -> URL {
        var localURL = FileSystemHelper.cachesUrl()
        localURL.appendPathComponent(remoteUrl.sha256Hash())
        return localURL
    }
    
    // MARK: - States
    
    private func cleanCurrentConfiguration() {
        imageURL = nil
        image = nil
        removeLoadingMode()
    }
    
    private func presentLoadingMode() {
        if let defualtImage = CurrentRemoteImageViewConfiguration.defaultImage {
            image = defualtImage
        } else if spinner == nil {
            image = nil
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.tag = Self.spinnerTag
            addSubview(spinner)
            
            spinner.startAnimating()
            spinner.center = CGPoint(x: bounds.size.width / 2.0,
                                     y: bounds.size.height / 2.0)
            
            spinner.autoresizingMask = [.flexibleBottomMargin,
                                        .flexibleLeftMargin,
                                        .flexibleRightMargin,
                                        .flexibleTopMargin]
        }
    }
    
    private func removeLoadingMode() {
        spinner?.removeFromSuperview()
    }
    
    private func presentErrorMode() {
        image = nil
        removeLoadingMode()
    }
    
}
