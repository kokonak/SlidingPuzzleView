//
//  SlidingPuzzleView.swift
//  SlidingPuzzleView
//
//  Created by KOKONAK on 2017. 6. 21..
//  Copyright © 2017년 KOKONAK. All rights reserved.
//

import UIKit

protocol puzzleDelegate {
    func puzzleComplete(view: SlidingPuzzleView)
    func puzzleSwapCount(view: SlidingPuzzleView, count: Int)
}

enum puzzleLevel: Int {
    case veryEasy = 2
    case easy = 3
    case normal = 4
    case hard = 5
}

@IBDesignable
class SlidingPuzzleView: UIView {
    private enum moveDirection: Int {
        case up = 0
        case down = 1
        case left = 2
        case right = 3
    }

    @IBInspectable var puzzleImage: UIImage?
    
    
    var pieceBorderColor: UIColor = UIColor.lightGray
    var pieceBorderWidth: CGFloat = 0.5
    
    var level: puzzleLevel = .easy
    var swapDuration: Double = 0.3
    var delegate: puzzleDelegate?

    private(set) var swapCount: Int = 0
    
    private let emptyPieceView: UIView = UIView()
    private var imagePiecesArray: [UIView] = []
    
    var pieceCount: Int {
        get {
            return Int(pow(CGFloat(self.level.rawValue), 2))
        }
    }
    
    // frame width and height must be equal
    override init(frame: CGRect) {
        super.init(frame: frame)
        if frame.width != frame.height {
            fatalError("frame width and height must be equal")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.frame.width != self.frame.height {
            fatalError("frame width and height must be equal")
        }
    }
    
    func startPuzzle() {
        self.createPuzzlePeices()
        self.shufflePieces()
    }
    
    // Create image view pieces
    private func createPuzzlePeices() {
        guard let puzzleImage: UIImage = self.puzzleImage else {
            print("image is nil")
            return
        }
        
        let pieceImageWidth: CGFloat = (puzzleImage.size.height > puzzleImage.size.width ? puzzleImage.size.width : puzzleImage.size.height) / CGFloat(self.level.rawValue)
        for i in 0..<self.pieceCount-1 {
            let imageRect: CGRect = CGRect(x: CGFloat(i % self.level.rawValue) * pieceImageWidth, y: CGFloat(i / self.level.rawValue) * pieceImageWidth, width: pieceImageWidth, height: pieceImageWidth)
            
            let tmpImageRef: CGImage = puzzleImage.cgImage!
            let pieceImageRef: CGImage = tmpImageRef.cropping(to: imageRect)!
            let pieceImage: UIImage = UIImage(cgImage: pieceImageRef)
            
            let imgView: UIImageView = UIImageView()
            imgView.image = pieceImage
            imgView.tag = i
            imgView.layer.borderWidth = self.pieceBorderWidth
            imgView.layer.borderColor = self.pieceBorderColor.cgColor
            imgView.isUserInteractionEnabled = true
            self.addGesture(view: imgView)
            self.imagePiecesArray.append(imgView)
            
            self.addSubview(imgView)
        }
        self.emptyPieceView.tag = self.pieceCount-1
        self.imagePiecesArray.append(self.emptyPieceView)
        self.addSubview(self.emptyPieceView)
    }
    
    
    // shuffle imagePiecesArray
    func shufflePieces() {
        for view in self.imagePiecesArray {
            view.layer.removeAllAnimations()
        }
        
        self.swapCount = 0
    
        
        repeat {
            for _ in 0..<100 {
                self.randomSwap()
            }
        } while self.completionCheck()
        
        
        let pieceViewWidth: CGFloat = self.frame.width / CGFloat(self.level.rawValue)
        for (i, view) in self.imagePiecesArray.enumerated() {
            let viewRect: CGRect = CGRect(x: CGFloat(i % self.level.rawValue) * pieceViewWidth, y: CGFloat(i / self.level.rawValue) * pieceViewWidth, width: pieceViewWidth, height: pieceViewWidth)
            view.frame = viewRect
        }
    }
    private func randomSwap() {
        guard let emptyPieceViewIndex = self.imagePiecesArray.index(of: self.emptyPieceView) else {
            fatalError("Array didn't contain empty piece.")
        }
        let directionArray = self.possibleMoveDirection(index: emptyPieceViewIndex)
        if directionArray.count == 0 {
            return
        }
        
        let direction: moveDirection = directionArray[Int(arc4random_uniform(UInt32(directionArray.count)))]
        
        var index: Int = 0
        
        switch direction {
        case .up:
            index = -self.level.rawValue
        case .down:
            index = self.level.rawValue
        case .left:
            index = -1
        case .right:
            index = 1
        }
        
        self.swapImagePiecesArray(index1: emptyPieceViewIndex, index2: emptyPieceViewIndex + index)
    }
    
    private func swapImagePiecesArray(index1: Int, index2: Int) {
        let temp: UIView = self.imagePiecesArray[index1]
        self.imagePiecesArray[index1] = self.imagePiecesArray[index2]
        self.imagePiecesArray[index2] = temp
    }
    
    private func possibleMoveDirection(index: Int) -> [moveDirection] {
        let row: Int = index / self.level.rawValue
        let column: Int = index % self.level.rawValue
        
        var possibleMoveDirection: [moveDirection] = []
        
        if row == 0 {
            possibleMoveDirection.append(.down)
        }
        else if row == self.level.rawValue - 1 {
            possibleMoveDirection.append(.up)
        }
        else {
            possibleMoveDirection.append(.up)
            possibleMoveDirection.append(.down)
        }
        
        if column == 0 {
            possibleMoveDirection.append(.right)
        }
        else if column == self.level.rawValue - 1 {
            possibleMoveDirection.append(.left)
        }
        else {
            possibleMoveDirection.append(.right)
            possibleMoveDirection.append(.left)
        }
        
        return possibleMoveDirection
    }

    
    private func addGesture(view: UIView) {
        view.gestureRecognizers?.removeAll()
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(tapGestureAction(gesture:)))
        view.addGestureRecognizer(gesture)
    }
    @objc private func tapGestureAction(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else {
            print("view is nil")
            return
        }
        guard let tapViewIndex = self.imagePiecesArray.index(of: view) else {
            print("Array is not contain the view.")
            return
        }
        guard let emptyPieceViewIndex = self.imagePiecesArray.index(of: self.emptyPieceView) else {
            print("Array is not contain empty view.")
            return
        }
        
        let emptyPieceViewRow = emptyPieceViewIndex / self.level.rawValue
        let viewRow = tapViewIndex / self.level.rawValue
        
        
        // Examine if tapped piece and empty piece can swap.
        if emptyPieceViewRow == viewRow {
            if tapViewIndex == emptyPieceViewIndex + 1 ||
                tapViewIndex == emptyPieceViewIndex - 1 {
                self.swapImagePiecesArray(index1: emptyPieceViewIndex, index2: tapViewIndex)
                self.viewSwapAnimation(view1: view, view2: self.emptyPieceView)
            }
        }
        else {
            if tapViewIndex == emptyPieceViewIndex + self.level.rawValue ||
                tapViewIndex == emptyPieceViewIndex - self.level.rawValue {
                self.swapImagePiecesArray(index1: emptyPieceViewIndex, index2: tapViewIndex)
                self.viewSwapAnimation(view1: view, view2: self.emptyPieceView)
            }
        }
    }
    private func viewSwapAnimation(view1: UIView, view2: UIView) {
        self.swapCount += 1
        self.delegate?.puzzleSwapCount(view: self, count: self.swapCount)

        UIView.animate(withDuration: self.swapDuration, animations: {
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
        for (index, view) in self.imagePiecesArray.enumerated() {
            if index != view.tag {
                return false
            }
        }
        return true
    }
}
