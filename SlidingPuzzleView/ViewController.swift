//
//  ViewController.swift
//  SlidingPuzzleView
//
//  Created by KOKONAK on 2017. 6. 21..
//  Copyright © 2017년 KOKONAK. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, PuzzleDelegate {

    @IBOutlet weak var puzzleView: SlidingPuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        view.layoutIfNeeded()
        puzzleView.delegate = self
        puzzleView.startPuzzle()
    }

    @IBAction func ShuffleTouch(_ sender: Any) {
        puzzleView.shuffle()
    }
    
    func puzzleComplete(view: SlidingPuzzleView) {
        print("complete")
        let controller = UIAlertController(title: "Complete", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Ok", style: .default)
        controller.addAction(confirm)
        present(controller, animated: true)
    }

    func puzzleSwapCount(view: SlidingPuzzleView, count: Int) {
        print(count)
    }
}

