//
//  ViewController.swift
//  SlidingPuzzleView
//
//  Created by KOKONAK on 2017. 6. 21..
//  Copyright © 2017년 KOKONAK. All rights reserved.
//

import UIKit

class ViewController: UIViewController, puzzleDelegate {

    @IBOutlet weak var puzzleView: SlidingPuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.puzzleView.delegate = self
        self.puzzleView.startPuzzle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ShuffleTouch(_ sender: Any) {
        self.puzzleView.shufflePieces()
    }
    
    func puzzleComplete(view: SlidingPuzzleView) {
        print("complete")
        let alert: UIAlertView = UIAlertView(title: "Puzzle complete", message: nil, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    func puzzleSwapCount(view: SlidingPuzzleView, count: Int) {
        print(count)
    }
}

