//
//  Sample.swift
//

import Foundation

class Sample
{
    let queue = DownloadQueue.shared // shared download queue
    var pendingDownloads = [UUID]() // track the remaining downloads so we can cancel them
    
    func download()
    {
        let imageUrls = ["https://url/file1.dat",
                         "https://url/file2.dat",
                         "https://url/file3.dat"]
        
        for imageUrl in imageUrls
        {
            if let url = URL(string: imageUrl)
            {
                // add items to the queue
                let taskId = queue.queueDownload(url: url, completion: gotData)
                
                // track the ID's that are still in progress
                pendingDownloads.append(taskId)
            }
        }
    }
    
    func gotData(id: UUID, data: Data?)
    {
        if let index = pendingDownloads.index(of: id)
        {
            // this download is done; we don't need to track it anymore
            pendingDownloads.remove(at: index)
        }
        
        if (data != nil)
        {
            // we have the data we need, so the others can be removed.
            for pendingDownload in pendingDownloads
            {
                queue.remove(id: pendingDownload)
            }
        }
    }
}
