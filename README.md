# **SlidingPuzzleView**
[![Language](https://img.shields.io/badge/language-Swift%203.1-orange.svg?style=flat)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)]()
[![iOS](https://img.shields.io/badge/iOS-8.0%2B-brightgreen.svg?style=flat)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/kokonak/SlidingPuzzleView/blob/master/LICENSE)

![](puzzle.gif)

## About

`SlidingPuzzleView` is a simple view written in Swift for implement sliding puzzle. Create a view, set a couple properties and execute `startPuzzle()`!

## Usage

- Properties must set before executing `startPuzzle()`
- SlidingPuzzleView frame width and height must be equal.

```swift
let width: CGFloat = 300
let puzzleView: SlidingPuzzleView = SlidingPuzzleView(frame: CGRect(0, 0, width, width))
puzzleView.level = .normal
puzzleView.puzzleImage = UIImage(named: "image")
puzzleView.delegate = self

puzzleView.startPuzzle()
```

## Properties

| Property | Type | Description |
|---------|:------|:------------|
|pieceBorderColor|UIColor| Piece border color|
|pieceBorderWidth|CGFloat| Piece border width|
|level|puzzleLevel|4 difficulty levels. veryEasy(2 x 2), easy(3 x 3), normal(4 x 4), hard(5 x 5)|
|swapDuration|Double|Duration for swap animation|
|puzzleImage|UIImage|Image for puzzle|
|delegate|puzzleDelegate|Delegate (puzzleComplete, puzzleSwapCount)|
|swapCount|Int|The number of times that the user has moved a piece.|

## Author

kokonak, <a src="mailto:kokonak7@gmail.com">kokonak7@gmail.com</a>

## License

_SlidingPuzzleView_ is available under the MIT license. See the [LICENSE](https://github.com/kokonak/SlidingPuzzleView/blob/master/LICENSE) file for more info.
