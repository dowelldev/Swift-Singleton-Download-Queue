//
//  DownloadQueue.swift
//

import Foundation

class DownloadQueue {
    
    //Singleton
    static let shared = DownloadQueue()
    
    //URLSession
    private let defaultSession = URLSession(configuration: .default)
    
    //Queue and current item
    private var items = [_queueItem]()
    private var currentItem: _queueItem?
    private var downloadTask: URLSessionDataTask? = nil
    
    private init() { }
    
    // Add an item to the queue
    func queueDownload(url: URL, completion: @escaping (UUID, Data?) -> ()) -> (UUID)
    {
        let id = UUID()
        let item = _queueItem(id: id, url: url, completion: completion)
        items.append(item)
        startDownload()
        
        return id
    }
    
    // Remove an item from the queue
    func remove(id: UUID)
    {
        if let index = items.index(where: { $0.id == id })
        {
            NSLog("remove from queue: \(index)")
            items.remove(at: index)
        }
        if (currentItem?.id == id)
        {
            NSLog("cancel current item \(id.uuidString)")
            downloadTask?.cancel()
        }
    }
    
    // Start the download
    private func startDownload()
    {
        if (downloadTask == nil && items.count > 0)
        {
            let item = items.removeFirst()
            currentItem = item
            let url = item.url
            downloadTask = defaultSession.dataTask(with: url)
            {[unowned self]
                data, response, error in
                
                // Reset the current items and send the completion
                self.downloadTask = nil
                self.currentItem = nil
                DispatchQueue.main.async {
                    item.completion(item.id, data)
                }
                self.startDownload()
            }
            downloadTask?.resume()
        }
    }
    
    // Queueable items
    private struct _queueItem
    {
        let id: UUID
        let url: URL
        let completion: (UUID, Data?) -> ()
    }
}
