//
//  DocumentPicker.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 28.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol DocumentDelegate: class {
    func didPickURL(_ url: URL?)
}

class Document: UIDocument {
    var data: Data?
    override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject:data,
                                                requiringSecureCoding: true)
    }
    override func load(fromContents contents: Any, ofType typeName:
        String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }
}

open class DocumentPicker: NSObject {
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentDelegate?

    private var pickedDocument: Document?

    init(presentationController: UIViewController, delegate: DocumentDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }

    public func displayPicker() {
        self.pickerController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeFolder)],  in: .open)
        self.pickerController!.delegate = self
        self.presentationController?.present(self.pickerController!, animated: true)
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {

    /// delegate method, when the user selects a file
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        delegate?.didPickURL(url)
    }

    /// delegate method, when the user cancels
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.didPickURL(nil)
    }

    private func documentFromURL(pickedURL: URL) {
        
        /// start accessing the resource
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()

        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (readURL) in
            let document = Document(fileURL: readURL)
            pickedDocument = document
        }
    }
}
