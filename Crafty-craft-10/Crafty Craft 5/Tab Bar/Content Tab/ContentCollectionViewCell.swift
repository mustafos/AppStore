import UIKit

final class ContentCollectionViewCell: UICollectionViewCell {
    
    typealias ImageDataCallback = (Data?) -> Void
    // MARK: - Outlets
    
    @IBOutlet private weak var roundedBackgroundView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newIcon: UIImageView!
    @IBOutlet weak var contentImageView: CustomImageLoader!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var headerLabContainerView: UIView!
    
    private let imageSemaphore = DispatchSemaphore(value: 0)
    private var imageUrl: URL?
    private var image: UIImage?
    
    private lazy var imageService = ImageService()
    private var imageRequest: Cancellable?
    private var imageDataCallback: ImageDataCallback?
    
    private var imageFetchOperation: DispatchWorkItem = .init(block: {})
    private var imageDownloadOperation: DispatchWorkItem = .init(block: {})
    private var imageApplyOperation: DispatchWorkItem = .init(block: {})
    
    private lazy var loader = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.tintColor = .black
        return activityView
    }()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
        backgroundColor = .clear
        contentImageView.backgroundColor = .clear
        
        self.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentImageView.image = nil
        
        imageUrl = .none
        image = .none
        
        imageRequest?.cancel()
        imageFetchOperation.cancel()
        imageDownloadOperation.cancel()
        imageApplyOperation.cancel()
        
        imageDataCallback = nil
    }
    
    // MARK: - Public Methods
    
    func configure(model: TabPagesCollectionCellModel, queue: DispatchQueue, completion: @escaping ImageDataCallback) {
        DispatchQueue.main.async {
            self.addLoader()
        }
        self.imageDataCallback = completion
        
        let imageName = model.image
        
        imageFetchOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageFetchOperation.isCancelled == false else {
                return
            }
            
            self?.fetchDropboxUrl(by: imageName)
        })
        
        imageDownloadOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageDownloadOperation.isCancelled == false else {
                return
            }
            
            guard let url = self?.imageUrl else {
                return
            }
            
            self?.fetchImage(from: url)
        })
        
        imageApplyOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageApplyOperation.isCancelled == false else {
                return
            }
            
            let img = self?.image ?? UIImage(named: "close cross")
            
            // Update Thumbnail Image View
            DispatchQueue.main.async {
                self?.removeLoader()
                self?.contentImageView.image = img
            }
            
            if let imageDataCallback = self?.imageDataCallback {
                imageDataCallback(self?.image?.pngData())
            }
        })
        
        queue.async(execute: imageFetchOperation)
        queue.async(execute: imageDownloadOperation)
        queue.async(execute: imageApplyOperation)
    }
    
    private func addLoader() {
        loader.color = .black
        addSubview(loader)
        bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.startAnimating()
    }
    
    private func removeLoader() {
        loader.removeFromSuperview()
    }
    
    private func fetchDropboxUrl(by name: String) {
        DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: name) { [weak self] stringUrl in
            if let stringUrl, let url = URL(string: stringUrl) {
                self?.imageUrl = url
            } else {
                // data from url == error
                self?.imageUrl = .none
                self?.image = .none
                
                self?.imageDownloadOperation.cancel()
                
                DispatchQueue.main.async {
                    self?.contentImageView.image = UIImage(named: "close cross")
                }
            }
            self?.imageSemaphore.signal()
        }
        imageSemaphore.wait()
    }
    
    private func fetchImage(from url: URL) {
        if let imageUrl {
            imageRequest = imageService.image(for: imageUrl) { [weak self] image in
                self?.image = image
                self?.imageSemaphore.signal()
            }
            imageSemaphore.wait()
        }
    }
    
    func configure(imageUrl: URL, completion: @escaping (Data?) -> Void) {
        // Request Image Using Image Service
        imageRequest = imageService.image(for: imageUrl) { [weak self] image in
            // Update Thumbnail Image View
            self?.contentImageView.image = image
            completion(image?.pngData())
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        setupRoundedBackgroundView()
        setupHeaderLabContainerViewl()
        setupContentImageView()
    }
    
    private func setupRoundedBackgroundView() {
        roundedBackgroundView.roundCorners()
    }
    
    private func setupHeaderLabContainerViewl() {
        headerLabContainerView.roundCorners([.allCorners], radius: 8)
    }
    
    private func setupContentImageView() {
        contentImageView.roundCorners([.allCorners], radius: 8)
    }
}
