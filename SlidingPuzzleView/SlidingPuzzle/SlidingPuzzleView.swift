//
//  SlidingPuzzleView.swift
//  SlidingPuzzleView
//
//  Created by KOKONAK on 2017. 6. 21..
//  Copyright © 2017년 KOKONAK. All rights reserved.
//

import UIKit

protocol PuzzleDelegate: AnyObject {
    func puzzleComplete(view: SlidingPuzzleView)
    func puzzleSwapCount(view: SlidingPuzzleView, count: Int)
}

@IBDesignable
final class SlidingPuzzleView: UIView {

    @IBInspectable var puzzleImage: UIImage?

    var pieceBorderColor: UIColor = UIColor.lightGray {
        didSet { puzzleImageViews.forEach { $0.layer.borderColor = pieceBorderColor.cgColor } }
    }

    var pieceBorderWidth: CGFloat = 0.5 {
        didSet { puzzleImageViews.forEach { $0.layer.borderWidth = pieceBorderWidth } }
    }
    
    var level: PuzzleLevel = .easy
    var swapAnimationDuration: Double = 0.2
    weak var delegate: PuzzleDelegate?

    private(set) var swapCount: Int = 0
    private let emptyPieceView = UIView()
    private var puzzleImageViews: [UIView] = []
    
    var pieceCount: Int {
        get { Int(pow(CGFloat(level.rawValue), 2)) }
    }
    
    // frame width and height must be equal
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkSquare()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        checkSquare()
    }

    private func checkSquare() {
        guard frame.width != frame.height else { return }
        fatalError("frame width and height must be equal")
    }
    
    func startPuzzle() {
        createPuzzlePeices()
    }
    
    private func createPuzzlePeices() {
        emptyPieceView.tag = -1
        puzzleImageViews.forEach { $0.removeFromSuperview() }
        puzzleImageViews.removeAll()

        generatePieces()
        setPuzzlePieceFrame()
    }

    private func generatePieces() {
        guard let image = puzzleImage else { return }

        // 이미지가 정사각형이 아니라면 길이가 작은면을 기준으로 정사각형으로 이미지를 자름.
        let imageWidth: CGFloat
        if image.size.height > image.size.width {
            imageWidth = image.size.width
        } else {
            imageWidth = image.size.height
        }
        let pieceImageWidth: CGFloat = imageWidth / CGFloat(level.rawValue)

        for i in 0..<(pieceCount - 1) {
            let imagePieceFrame: CGRect = CGRect(
                x: CGFloat(i % level.rawValue) * pieceImageWidth,
                y: CGFloat(i / level.rawValue) * pieceImageWidth,
                width: pieceImageWidth,
                height: pieceImageWidth
            )

            guard let pieceImageRef: CGImage = image.cgImage?.cropping(to: imagePieceFrame) else {
                fatalError("failed to created puzzle")
            }

            let pieceImage: UIImage = UIImage(cgImage: pieceImageRef)
            let imageView: UIImageView = UIImageView()
            imageView.image = pieceImage
            imageView.tag = i
            imageView.layer.borderWidth = pieceBorderWidth
            imageView.layer.borderColor = pieceBorderColor.cgColor
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            addSubview(imageView)

            let gesture: UITapGestureRecognizer = UITapGestureRecognizer()
            gesture.addTarget(self, action: #selector(tapGestureAction(gesture:)))
            imageView.addGestureRecognizer(gesture)

            puzzleImageViews.append(imageView)
        }
        emptyPieceView.tag = puzzleImageViews.count
        puzzleImageViews.append(emptyPieceView)
    }

    private func setPuzzlePieceFrame() {
        let pieceViewWidth: CGFloat = frame.width / CGFloat(level.rawValue)
        puzzleImageViews.enumerated().forEach {
            $1.frame = CGRect(
                x: CGFloat($0 % level.rawValue) * pieceViewWidth,
                y: CGFloat($0 / level.rawValue) * pieceViewWidth,
                width: pieceViewWidth,
                height: pieceViewWidth
            )
        }
    }

    func shuffle() {
        puzzleImageViews.forEach { $0.layer.removeAllAnimations() }
        swapCount = 0

        repeat {
            (0..<100).forEach { _ in randomlyShuffle() }
        } while completionCheck()

        setPuzzlePieceFrame()
    }

    private func randomlyShuffle() {
        guard let emptyPieceIndex = puzzleImageViews.firstIndex(of: emptyPieceView) else {
            fatalError("emptyPiece are missing")
        }

        let directionArray = getPossibleMovingDirection(index: emptyPieceIndex)
        guard directionArray.count > 0 else { return }

        let direction: MovingDirection = directionArray[Int(arc4random_uniform(UInt32(directionArray.count)))]
        var index: Int = 0
        switch direction {
            case .up:
                index = -level.rawValue
            case .down:
                index = level.rawValue
            case .left:
                index = -1
            case .right:
                index = 1
        }

        puzzleImageViews.swapAt(emptyPieceIndex, emptyPieceIndex + index)
    }

    private func getPossibleMovingDirection(index: Int) -> [MovingDirection] {
        let row: Int = index / level.rawValue
        let column: Int = index % level.rawValue
        
        var possibleMoveDirection: [MovingDirection] = []
        
        if row == 0 {
            possibleMoveDirection.append(.down)
        } else if row == level.rawValue - 1 {
            possibleMoveDirection.append(.up)
        } else {
            possibleMoveDirection.append(.up)
            possibleMoveDirection.append(.down)
        }
        
        if column == 0 {
            possibleMoveDirection.append(.right)
        } else if column == level.rawValue - 1 {
            possibleMoveDirection.append(.left)
        } else {
            possibleMoveDirection.append(.right)
            possibleMoveDirection.append(.left)
        }
        
        return possibleMoveDirection
    }

    @objc private func tapGestureAction(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        guard let tapPieceIndex = puzzleImageViews.firstIndex(of: view) else { return }
        guard let emptyPieceIndex = puzzleImageViews.firstIndex(of: emptyPieceView) else { return }

        let swapable: Bool = tapPieceIndex == emptyPieceIndex + 1
        || tapPieceIndex == emptyPieceIndex - 1
        || tapPieceIndex == emptyPieceIndex + level.rawValue
        || tapPieceIndex == emptyPieceIndex - level.rawValue

        guard swapable else { return }
        puzzleImageViews.swapAt(emptyPieceIndex, tapPieceIndex)
        viewSwapAnimation(view1: view, view2: emptyPieceView)
    }

    private func viewSwapAnimation(view1: UIView, view2: UIView) {
        swapCount += 1
        delegate?.puzzleSwapCount(view: self, count: swapCount)

        UIView.animate(withDuration: swapAnimationDuration, animations: {
            let tempRect = view1.frame
            view1.frame = view2.frame
            view2.frame = tempRect
        }) { (complete: Bool) in
            if self.completionCheck() {
                self.delegate?.puzzleComplete(view: self)
            }
        }
    }
    
    private func completionCheck() -> Bool {
        for (index, view) in puzzleImageViews.enumerated() {
            guard index != view.tag else { continue }
            return false
        }
        return true
    }
}
