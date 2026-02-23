//
//  AboutPCOSModel.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 23/02/26.
//

import Foundation

struct AboutPCOSSection {
    let title: String
    let description: String   // For Home Screen preview
       let imageName: String     // Used for BOTH home card & detail header
    let contentBlocks: [ContentBlock]
}

struct ContentBlock {
    let heading: String?
    let body: String?
    let imageName: String?
}
